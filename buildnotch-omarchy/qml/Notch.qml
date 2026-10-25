import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import "Lib.js" as Lib

// One notch per screen: a layer-shell overlay that only takes input over its own body.
PanelWindow {
    id: win
    required property var app
    readonly property var cfg: app.cfg

    property bool hovering: false
    property bool pinned: false
    property bool editing: false
    readonly property bool expanded: pinned || (cfg.hoverOpen && hovering)

    readonly property int maxW: 1080
    readonly property int bodyW: Math.min(maxW, screen.width - 32)
    readonly property int bodyH: Theme.barHeight + 8 + Theme.cardHeight + 16 + 34
    readonly property bool pill: cfg.placement === "pill"
    readonly property int pillH: Lib.pillHeight(topInset)
    readonly property int collH: pill ? pillH : 30
    readonly property int collR: pill ? pillH / 2 : 14
    readonly property var player: Mpris.players.values.filter(function (p) { return p.isPlaying; })[0] || null
    readonly property bool musicPlaying: player !== null
    readonly property int anim: cfg.reduceMotion ? 0 : 380

    // The pill is as wide as its hint; the offset notch keeps its fixed width.
    property real pillW: Math.max(40, pillRow.implicitWidth + 22)
    Behavior on pillW { NumberAnimation { duration: win.anim / 2; easing.type: Easing.OutCubic } }
    readonly property real collW: pill ? pillW : (cfg.shortNotch ? 150 : 210)

    // 0 = collapsed, 1 = open. Size, position and radius are all interpolated from it, so the notch
    // opens from wherever it sits (off centre, or over the bar) and shrinks back to the same spot.
    property real t: expanded ? 1 : 0
    Behavior on t { NumberAnimation { duration: win.anim; easing.type: Easing.OutCubic } }
    readonly property real collTop: pill ? ((topInset > 0 ? topInset : 30) - pillH) / 2 : topInset   // visible top edge when collapsed
    readonly property real shellTop: Lib.lerp(collTop, topInset, t)
    // The offset notch's top corners sit above its top edge (hidden behind the bar); the pill's do not until it opens.
    readonly property real hideTop: pill ? shellR * t : shellR
    readonly property real shellR: Lib.lerp(collR, Theme.shellRadius, t)
    // Clip line: the open notch must not paint over the bar above it, the pill must.
    readonly property real clipY: pill ? topInset * t : topInset

    // Space a bar (Waybar on Omarchy 3.x, Omarchy's own shell bar on 4.x) reserves at the top of this screen.
    // The notch hangs below it instead of covering it; `topOffset` in the config overrides the lookup.
    property int barReserved: 0
    readonly property int topInset: cfg.topOffset >= 0 ? cfg.topOffset : barReserved
    function readBar() {
        var m = Hyprland.monitorFor(screen);
        barReserved = Lib.reservedTop(m ? m.lastIpcObject : null);
    }
    Connections {
        target: Hyprland
        function onRawEvent(event) { if (event.name === "openlayer" || event.name === "closelayer") barTimer.restart(); }
    }
    Connections { target: Hyprland.monitorFor(win.screen); ignoreUnknownSignals: true; function onLastIpcObjectChanged() { win.readBar(); } }
    Timer { id: barTimer; interval: 120; onTriggered: { Hyprland.refreshMonitors(); win.readBar(); } }
    // Omarchy 4.x hides its bar by switching the layer's exclusion mode, which raises no layer event, so also
    // re-read the reserved space once a second; the monitor object only signals when the value really changed.
    Timer { interval: 1000; repeat: true; running: win.visible; onTriggered: Hyprland.refreshMonitors() }
    Component.onCompleted: barTimer.restart()

    // Concave "ears" where the notch meets the top edge, so it reads as one piece with the bezel.
    // The pill is a free-standing capsule, so it has none until it opens.
    readonly property real earRad: Lib.lerp(pill ? 0 : Theme.earRadiusCollapsed, Theme.earRadius, t)
    readonly property real shellScale: pill ? 1 : Lib.lerp(Theme.collapsedScale, 1, t)

    readonly property var cardWidths: ({ music: 340, pomodoro: 280, ai: 280, usage: 300, github: 300, projects: 320, quote: 280, apps: 280, note: 300 })
    readonly property var visibleIds: cfg.widgets.filter(function (w) { return w.visible; }).map(function (w) { return w.id; })
    function slotX(i) { var x = 0; for (var k = 0; k < i; k++) x += cardWidths[visibleIds[k]] + 14; return x; }
    readonly property int rowWidth: Math.max(0, slotX(visibleIds.length) - 14)

    visible: !app.fullscreen.hidden && (cfg.monitor === "" || screen.name === cfg.monitor)
    // Full width and from the very top edge, so the collapsed notch can sit anywhere along the bar; input is
    // limited to the notch body by the mask.
    anchors { top: true; left: true; right: true }
    implicitHeight: topInset + bodyH + 24
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: hit; regions: [Region { item: earL }, Region { item: earR }] }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "buildnotch"
    WlrLayershell.keyboardFocus: expanded ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    onExpandedChanged: {
        app.openCount += expanded ? 1 : -1;
        if (!expanded) { editing = false; topBar.bellOpen = false; }
    }

    Connections {
        target: win.app
        function onToggleRequested() {
            if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name !== win.screen.name) return;
            win.pinned = !win.expanded;
            if (!win.pinned) win.hovering = false;
        }
        function onPageRequested(page) {
            if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name !== win.screen.name) return;
            win.app.page = page; win.pinned = true;
        }
    }

    Timer { id: closeTimer; interval: 350; onTriggered: win.hovering = false }
    Timer { id: openTimer; interval: 90; onTriggered: win.hovering = true }

    Shortcut { sequence: "Escape"; enabled: win.expanded; onActivated: { win.pinned = false; win.hovering = false; } }
    Repeater {
        model: 6
        delegate: Item {
            required property int index
            Shortcut {
                sequence: "Alt+" + (index + 1); enabled: win.expanded
                onActivated: { var l = win.app.apps.ai; if (index < l.length) win.app.apps.launch(l[index]); }
            }
        }
    }

    // Everything is drawn inside `stage`, which starts at the clip line: below the bar for the open notch (so its
    // hidden top corners never paint over the bar), at the screen edge for the pill.
    Item {
    id: stage
    y: win.clipY; width: parent.width; height: parent.height - win.clipY; clip: true

    Rectangle {
        id: shell
        // The offset notch's top corners sit above its top edge, so only the bottom is rounded.
        property real r: win.hideTop
        x: Lib.lerp(Lib.collapsedLeft(win.cfg, win.screen.width, win.collW), (win.screen.width - win.bodyW) / 2, win.t)
        y: win.shellTop - win.clipY - r
        width: Lib.lerp(win.collW, win.bodyW, win.t)
        height: Lib.lerp(win.collH, win.bodyH, win.t) + r
        radius: win.shellR
        color: "#050708"
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, win.expanded ? 0.1 : 0.06)
        transformOrigin: Item.Top
        scale: win.shellScale
        clip: true

        // The part of the shell that is actually visible (the input region).
        Item { id: hit; y: shell.r; width: parent.width; height: parent.height - shell.r }

        HoverHandler {
            onHoveredChanged: {
                if (hovered) { closeTimer.stop(); openTimer.restart(); }
                else { openTimer.stop(); closeTimer.restart(); }
            }
        }

        // Custom wallpaper, rounded by a mask and dimmed so the controls stay readable.
        Rectangle { id: maskRect; anchors.fill: parent; radius: win.shellR; visible: false; layer.enabled: true }
        Image { id: wp; anchors.fill: parent; visible: false; fillMode: Image.PreserveAspectCrop; asynchronous: true
            source: win.cfg.wallpaper ? "file://" + win.cfg.wallpaper : "" }
        MultiEffect {
            anchors.fill: parent; source: wp; visible: wp.status === Image.Ready && win.expanded
            maskEnabled: true; maskSource: maskRect; brightness: -0.55
        }

        // ---- collapsed glance ----
        // Offset notch: clock, equaliser, timer. Pill: just a tiny hint (now playing, else the timer, else a dot).
        // Rows do not centre their children (anchors there trigger "scene" warnings), so each child gets a fixed
        // row height and the Text/bars are centred inside it.
        Row {
            id: pillRow
            anchors.horizontalCenter: parent.horizontalCenter; y: shell.r + (win.collH - height) / 2; spacing: win.pill ? 7 : 10
            height: win.collH
            opacity: win.expanded ? 0 : 1; visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 160 } }
            Item { visible: win.musicPlaying; width: eqRow.width; height: parent.height
                Row { id: eqRow; spacing: 2; height: 12; anchors.verticalCenter: parent.verticalCenter
                    Repeater { model: 3
                        delegate: Rectangle { id: eqBar; required property int index; property real barH: 10; width: 2.5; height: barH; radius: 1; color: Theme.phos; anchors.bottom: parent.bottom
                            SequentialAnimation { running: win.musicPlaying && !win.expanded && !win.cfg.reduceMotion; loops: Animation.Infinite
                                NumberAnimation { target: eqBar; property: "barH"; to: 4 + eqBar.index * 2; duration: 300 + eqBar.index * 90 }
                                NumberAnimation { target: eqBar; property: "barH"; to: 12; duration: 300 + eqBar.index * 70 } } } } } }
            Item { visible: !win.pill; width: clock.width; height: parent.height
                Text { id: clock; anchors.verticalCenter: parent.verticalCenter; color: "#fff"; font.pixelSize: 12; font.family: Theme.sans; font.weight: Font.DemiBold
                    text: Qt.formatTime(new Date(), "h:mm")
                    Timer { interval: 15000; repeat: true; running: !win.expanded && win.visible && !win.pill; triggeredOnStart: true; onTriggered: clock.text = Qt.formatTime(new Date(), "h:mm") } } }
            Item { visible: win.pill && win.musicPlaying; width: Math.min(110, track.implicitWidth); height: parent.height
                Text { id: track; anchors.verticalCenter: parent.verticalCenter; width: parent.width; elide: Text.ElideRight
                    text: win.player ? win.player.trackTitle : ""; color: Theme.text; font.pixelSize: 11; font.family: Theme.sans } }
            Item { visible: win.app.pomo.running; width: pomoHint.width; height: parent.height
                Text { id: pomoHint; anchors.verticalCenter: parent.verticalCenter; text: "◔ " + win.app.pomo.timeText; color: Theme.phos; font.pixelSize: 11; font.family: Theme.monoFamily } }
            Item { visible: win.pill && !win.musicPlaying && !win.app.pomo.running; width: 6; height: parent.height
                Rectangle { anchors.centerIn: parent; width: 6; height: 6; radius: 3; color: Theme.faint } }
        }
        // Collapsed: a click pins it open (also when "open on hover" is off).
        TapHandler { enabled: !win.expanded; onTapped: win.pinned = true }

        // ---- expanded content ----
        Item {
            id: content
            anchors.fill: parent; anchors.topMargin: shell.r
            opacity: win.expanded ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: win.expanded ? 260 : 120 } }

            TopBar {
                id: topBar
                app: win.app; width: parent.width
                editing: win.editing
                onEditToggled: { win.editing = !win.editing; win.app.page = "home"; }
                onCloseRequested: { win.pinned = false; win.hovering = false; }
                onPinToggled: win.pinned = !win.pinned
            }

            // Bell popup: recent notch events.
            Rectangle {
                visible: topBar.bellOpen; z: 20; x: parent.width - width - 60; y: topBar.height - 6; width: 260; height: Math.min(220, nl.contentHeight + 20); radius: 12
                color: Theme.glass; border.color: Theme.hair2; border.width: 1
                ListView { id: nl; anchors.fill: parent; anchors.margins: 10; clip: true; spacing: 6; model: win.app.notices
                    delegate: Text { required property var modelData; width: nl.width; elide: Text.ElideRight; color: Theme.text; font.pixelSize: 11; font.family: Theme.sans
                        text: modelData.text + "  ·  " + Lib.relTime(modelData.at) } }
                Text { visible: win.app.notices.length === 0; anchors.centerIn: parent; text: "No notifications"; color: Theme.faint; font.pixelSize: 11; font.family: Theme.sans }
            }

            Item {
                id: pageArea
                y: topBar.height + 8; width: parent.width; height: Theme.cardHeight

                Loader {
                    anchors.fill: parent
                    sourceComponent: ({ home: home, media: media, files: files, clipboard: clipboard, playground: playground, settings: settings })[win.app.page] || home
                }
            }

            // Hotkey bar
            Row {
                anchors.bottom: parent.bottom; anchors.bottomMargin: 10; x: 16; spacing: 22
                Kbd { keys: win.cfg.toggleHint; caption: "Toggle" }
                Kbd { keys: "Esc"; caption: "Close" }
                Kbd { keys: "Mouse wheel"; caption: "Browse cards" }
                Kbd { keys: "Alt + 1–6"; caption: "AI apps" }
            }
            Rectangle { anchors.bottom: parent.bottom; anchors.bottomMargin: 34; width: parent.width; height: 1; color: Theme.hair }
        }
    }

    // The ears follow the shell's animated edges (it scales about its top centre).
    Shape {
        id: earL
        readonly property real edge: shell.x + shell.width * (1 - shell.scale) / 2
        x: edge - width; y: win.shellTop - win.clipY; width: Theme.earRadius; height: Theme.earRadius
        visible: shell.visible && win.earRad > 0.5; preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: shell.color; strokeColor: "transparent"
            startX: earL.width - win.earRad; startY: 0
            PathLine { x: earL.width; y: 0 }
            PathLine { x: earL.width; y: win.earRad }
            PathArc { x: earL.width - win.earRad; y: 0; radiusX: win.earRad; radiusY: win.earRad; direction: PathArc.Counterclockwise }
        }
        // The shell's 1px border continues along the concave edge so the join is seamless.
        ShapePath {
            fillColor: "transparent"; strokeColor: shell.border.color; strokeWidth: shell.border.width
            startX: earL.width; startY: win.earRad
            PathArc { x: earL.width - win.earRad; y: 0; radiusX: win.earRad; radiusY: win.earRad; direction: PathArc.Counterclockwise }
        }
    }
    Shape {
        id: earR
        readonly property real edge: shell.x + shell.width - shell.width * (1 - shell.scale) / 2
        x: edge; y: win.shellTop - win.clipY; width: Theme.earRadius; height: Theme.earRadius
        visible: shell.visible && win.earRad > 0.5; preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: shell.color; strokeColor: "transparent"
            startX: 0; startY: win.earRad
            PathLine { x: 0; y: 0 }
            PathLine { x: win.earRad; y: 0 }
            PathArc { x: 0; y: win.earRad; radiusX: win.earRad; radiusY: win.earRad; direction: PathArc.Counterclockwise }
        }
        ShapePath {
            fillColor: "transparent"; strokeColor: shell.border.color; strokeWidth: shell.border.width
            startX: 0; startY: win.earRad
            PathArc { x: win.earRad; y: 0; radiusX: win.earRad; radiusY: win.earRad; direction: PathArc.Clockwise }
        }
    }
    }

    // ---- pages ----
    Component { id: media; Item { MusicCard { anchors.horizontalCenter: parent.horizontalCenter; app: win.app; big: true; height: parent.height } } }
    Component { id: files; FilesDrawer { app: win.app } }
    Component { id: clipboard; ClipboardDrawer { app: win.app } }
    Component { id: playground; PlaygroundDrawer { app: win.app } }
    Component { id: settings; SettingsDrawer { app: win.app } }

    Component {
        id: home
        Flickable {
            id: flick
            contentWidth: win.rowWidth + 32; contentHeight: height
            leftMargin: 16; rightMargin: 16; clip: true; boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.HorizontalFlick
            // Mouse wheel browses cards.
            WheelHandler {
                onWheel: event => {
                    var d = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x;
                    flick.contentX = Math.max(-flick.leftMargin, Math.min(flick.contentWidth - flick.width - flick.leftMargin, flick.contentX - d));
                }
            }
            Behavior on contentX { enabled: !flick.moving && !flick.dragging; NumberAnimation { duration: 120 } }

            Item {
                id: row
                width: win.rowWidth; height: parent.height
                Repeater {
                    model: win.visibleIds
                    delegate: Item {
                        id: slot
                        required property string modelData
                        required property int index
                        property real dragOffset: 0
                        property bool lifted: false
                        x: slotX + dragOffset
                        readonly property real slotX: win.slotX(index)
                        width: win.cardWidths[modelData]; height: Theme.cardHeight
                        z: lifted ? 10 : 0
                        scale: lifted ? 1.03 : 1
                        Behavior on x { enabled: !slot.lifted; NumberAnimation { duration: win.cfg.reduceMotion ? 0 : 220; easing.type: Easing.OutCubic } }
                        Behavior on scale { NumberAnimation { duration: 140 } }
                        // Jiggle in Edit mode, still otherwise and when animations are reduced.
                        SequentialAnimation on rotation {
                            running: win.editing && !win.cfg.reduceMotion && !slot.lifted; loops: Animation.Infinite
                            NumberAnimation { to: index % 2 ? -0.7 : 0.7; duration: 110 }
                            NumberAnimation { to: index % 2 ? 0.7 : -0.7; duration: 110 }
                            onRunningChanged: if (!running) slot.rotation = 0
                        }
                        Loader {
                            anchors.fill: parent
                            sourceComponent: ({ music: cMusic, pomodoro: cPomo, ai: cAi, usage: cUsage, github: cGh, projects: cProj,
                                                quote: cQuote, apps: cApps, note: cNote })[slot.modelData]
                        }
                        // Edit mode: grab to lift and reorder; the card settles into the slot it is released over.
                        MouseArea {
                            anchors.fill: parent; enabled: win.editing; visible: win.editing; z: 5; cursorShape: Qt.OpenHandCursor
                            property real startX: 0
                            onPressed: mouse => { slot.lifted = true; startX = mapToItem(row, mouse.x, 0).x; }
                            onPositionChanged: mouse => { if (slot.lifted) slot.dragOffset = mapToItem(row, mouse.x, 0).x - startX; }
                            onReleased: {
                                var center = slot.slotX + slot.dragOffset + slot.width / 2, to = slot.modelData, best = 1e9;
                                for (var i = 0; i < win.visibleIds.length; i++) {
                                    var c = win.slotX(i) + win.cardWidths[win.visibleIds[i]] / 2;
                                    if (Math.abs(c - center) < best) { best = Math.abs(c - center); to = win.visibleIds[i]; }
                                }
                                slot.lifted = false; slot.dragOffset = 0;
                                if (to !== slot.modelData) win.app.setCfg("widgets", Lib.moveWidget(win.cfg.widgets, slot.modelData, to));
                            }
                            Rectangle { anchors.fill: parent; radius: Theme.cardRadius; color: "transparent"; border.color: Theme.phos; border.width: 1; opacity: 0.55 }
                        }
                    }
                }
            }
        }
    }
    Component { id: cMusic; MusicCard { app: win.app } }
    Component { id: cPomo; PomodoroCard { app: win.app } }
    Component { id: cAi; AiCard { app: win.app } }
    Component { id: cUsage; UsageCard { app: win.app } }
    Component { id: cGh; GithubCard { app: win.app } }
    Component { id: cProj; ProjectsCard { app: win.app } }
    Component { id: cQuote; QuoteCard { app: win.app } }
    Component { id: cApps; AppsCard { app: win.app } }
    Component { id: cNote; NoteCard { app: win.app } }
}
