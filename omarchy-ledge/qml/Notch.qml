import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// One notch per screen: a layer-shell overlay that only captures input over its own body.
PanelWindow {
    id: win
    required property var cfg
    required property var store
    required property var timer
    signal popOutTimer()

    readonly property var c: cfg.colors
    property bool open: false
    property bool pinned: false
    property int tab: 0
    readonly property bool expanded: open || pinned
    readonly property int radius: 16

    anchors { top: true }
    margins.top: 0
    implicitWidth: cfg.expandedWidth
    implicitHeight: cfg.expandedHeight
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: body }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "ledge"
    WlrLayershell.keyboardFocus: expanded ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Timer { id: openTimer; interval: win.cfg.hoverDelayMs; onTriggered: win.open = true }
    Timer { id: closeTimer; interval: win.cfg.collapseDelayMs; onTriggered: win.open = false }

    Rectangle {
        id: body
        anchors.horizontalCenter: parent.horizontalCenter
        // Top corners sit above the screen edge so only the bottom is rounded.
        y: -win.radius
        width: win.expanded ? win.cfg.expandedWidth : win.cfg.collapsedWidth
        height: (win.expanded ? win.cfg.expandedHeight : win.cfg.collapsedHeight) + win.radius
        radius: win.radius
        color: c.bg
        clip: true

        Behavior on width { NumberAnimation { duration: win.cfg.animationMs; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: win.cfg.animationMs; easing.type: Easing.OutCubic } }

        HoverHandler {
            onHoveredChanged: {
                if (hovered) { closeTimer.stop(); openTimer.restart(); }
                else { openTimer.stop(); closeTimer.restart(); }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: win.radius + 6
            anchors.margins: 14
            spacing: 10
            opacity: win.expanded ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: win.cfg.animationMs } }

            // Header: tabs + pin. Clicking empty header space also toggles the pin.
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                Repeater {
                    model: ["Music", "Timer", "Tasks", "Shortcuts", "GitHub"]
                    delegate: Btn {
                        required property string modelData
                        required property int index
                        label: modelData
                        primary: index === win.tab; accent: c.accent; fg: c.fg; surface: c.surface
                        onClicked: win.tab = index
                    }
                }
                Item {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    TapHandler { onTapped: win.pinned = !win.pinned }
                }
                Btn {
                    label: win.pinned ? "📌 Pinned" : "Pin"
                    primary: win.pinned; accent: c.accent; fg: c.fg; surface: c.surface
                    onClicked: win.pinned = !win.pinned
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: win.tab
                MusicPanel { cfg: win.cfg }
                Item {
                    TimerView { anchors.centerIn: parent; timer: win.timer; cfg: win.cfg; onPopOut: win.popOutTimer() }
                }
                TasksPanel { cfg: win.cfg; store: win.store }
                ShortcutsPanel { cfg: win.cfg }
                GithubPanel { cfg: win.cfg }
            }
        }

        // Collapsed: any click pins it open.
        TapHandler { enabled: !win.expanded; onTapped: win.pinned = true }
    }
}
