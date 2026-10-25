import QtQuick

// The focus timer in all seven styles. Used by the card, the Settings preview and the floating window.
Item {
    id: v
    required property var app
    property bool compact: false
    readonly property var m: app.pomo
    readonly property string style: app.cfg.pomoStyle
    readonly property var modes: [{ k: "focus", l: "Focus" }, { k: "short", l: "Short" }, { k: "long", l: "Long" }]

    function bigFont() { return compact ? 0.8 : 1; }

    // ---- shared pieces ----
    component ModeRow: Row {
        id: mrow
        property color selColor: "#ffffff"
        property color selText: "#0a0b0d"
        property color offColor: "transparent"
        property color offText: Theme.text
        property string family: Theme.sans
        property int px: 12
        spacing: 6
        Repeater {
            model: v.modes
            delegate: Btn {
                required property var modelData
                label: modelData.l; active: v.m.mode === modelData.k
                activeColor: mrow.selColor; activeText: mrow.selText; idleColor: mrow.offColor; idleText: mrow.offText
                family: mrow.family; pixelSize: mrow.px
                onClicked: v.m.setMode(modelData.k)
            }
        }
    }
    component Dots: Row {
        id: drow
        property color selColor: "#ffffff"
        property color offColor: Qt.rgba(1, 1, 1, 0.2)
        spacing: 5
        Repeater {
            model: 4
            delegate: Rectangle {
                required property int index
                width: 6; height: 6; radius: 3
                color: index < ((v.m.session - 1) % 4) ? drow.selColor : drow.offColor
            }
        }
    }
    // Length editor: click the minutes to type a new value ("update the timer, custom timers").
    component Minutes: Row {
        property color tint: Theme.dim
        property string family: Theme.sans
        spacing: 4
        Text { text: "–"; color: parent.tint; font.pixelSize: 14; font.family: parent.family
            MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: v.step(-1) } }
        Text { text: Math.round(v.m.total / 60) + " Min"; color: parent.tint; font.pixelSize: 11; font.family: parent.family }
        Text { text: "+"; color: parent.tint; font.pixelSize: 14; font.family: parent.family
            MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: v.step(1) } }
    }
    function step(d) {
        var key = m.mode === "focus" ? "focusMin" : (m.mode === "short" ? "shortMin" : "longMin");
        var next = Math.max(1, Math.min(180, app.cfg[key] + d));
        app.setCfg(key, next);
    }
    component PlaySquare: Rectangle {
        property color fillColor: "transparent"
        property color glyph: Theme.text
        width: 36; height: 36; radius: 8; color: fillColor
        Text { anchors.centerIn: parent; text: v.m.running ? "⏸" : "▶"; color: parent.glyph; font.pixelSize: 15 }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: v.m.toggle() }
    }

    Loader {
        anchors.fill: parent
        sourceComponent: ({ clean: clean, pixel: pixel, dots: dots, retro: retro, terminal: terminal, zen: zen, cyber: cyber })[v.style] || clean
    }

    // 1. Clean: white ring, tomato, one pill row.
    Component {
        id: clean
        Item {
            Ring { id: ring; width: 150 * v.bigFont(); height: width; anchors.horizontalCenter: parent.horizontalCenter; y: 6
                progress: v.m.progress; fill: "#fff" }
            Column {
                anchors.centerIn: ring; spacing: 0
                Image { anchors.horizontalCenter: parent.horizontalCenter; source: "assets/tomato.png"; width: 34; height: 34; smooth: true }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: v.m.timeText; color: "#fff"; font.pixelSize: 30 * v.bigFont(); font.family: Theme.sans; font.weight: Font.Bold }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: v.m.stateText; color: Theme.dim; font.pixelSize: 10; font.family: Theme.monoFamily; font.letterSpacing: 1.5 }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter; y: ring.y + ring.height + 8; spacing: 14
                PlaySquare { }
                Minutes { anchors.verticalCenter: parent.verticalCenter }
                Dots { anchors.verticalCenter: parent.verticalCenter }
            }
            ModeRow { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom }
        }
    }

    // 2. Pixel dusk: purple dusk panel, pixel cat, Press Start 2P time, salmon accents.
    Component {
        id: pixel
        Rectangle {
            radius: 16; color: "#211a2c"
            Ring { id: ring; width: 150 * v.bigFont(); height: width; anchors.horizontalCenter: parent.horizontalCenter; y: 6
                progress: v.m.progress; track: "#493a57"; fill: "#ffb4a2"; stroke: 5; knob: true; knobColor: "#ff8fa3" }
            Column {
                anchors.centerIn: ring; spacing: 4
                Image { anchors.horizontalCenter: parent.horizontalCenter; source: "assets/pixel-cat.png"; width: 30; height: 21; smooth: false }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: v.m.timeText; color: "#fff4e8"; font.pixelSize: 17 * v.bigFont(); font.family: Theme.pixelFamily; style: Text.Raised; styleColor: "#6f557e" }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: v.m.stateText; color: "#cfc0dd"; font.pixelSize: 9; font.family: Theme.pixelFamily }
            }
            PlaySquare { fillColor: "#ffa08f"; glyph: "#2a1d33"; anchors.horizontalCenter: parent.horizontalCenter; y: ring.y + ring.height + 8 }
            ModeRow { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 8
                selColor: "#ffa08f"; selText: "#2a1d33"; offText: "#fff4e8"; family: Theme.pixelFamily; px: 9 }
        }
    }

    // 3. Dots: the ring is a circle of 60 dots.
    Component {
        id: dots
        Item {
            Ring { id: ring; width: 156 * v.bigFont(); height: width; anchors.horizontalCenter: parent.horizontalCenter; y: 4
                dots: true; stroke: 6; progress: v.m.progress; fill: Theme.phos; track: Qt.rgba(1, 1, 1, 0.14) }
            Column {
                anchors.centerIn: ring; spacing: 2
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: v.m.timeText; color: "#fff"; font.pixelSize: 30 * v.bigFont(); font.family: Theme.monoFamily; font.weight: Font.Bold }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: v.m.stateText; color: Theme.phos; font.pixelSize: 10; font.family: Theme.monoFamily }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter; y: ring.y + ring.height + 8; spacing: 14
                PlaySquare { fillColor: Theme.phosDim; glyph: Theme.phos }
                Dots { anchors.verticalCenter: parent.verticalCenter; selColor: Theme.phos }
            }
            ModeRow { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; selColor: Theme.phos; selText: "#04140c"; family: Theme.monoFamily }
        }
    }

    // 4. Retro clock: LCD display.
    Component {
        id: retro
        Rectangle {
            radius: 16; color: "#2c2e22"
            Rectangle {
                id: lcd; anchors.horizontalCenter: parent.horizontalCenter; y: 12; width: parent.width - 28; height: 112 * v.bigFont(); radius: 8
                color: "#a7b08a"; border.color: "#5a5e48"; border.width: 3
                Row {
                    anchors.centerIn: parent; spacing: 10
                    Text { text: v.m.timeText; color: "#10180a"; font.pixelSize: 52 * v.bigFont(); font.family: Theme.vtFamily }
                }
                Rectangle { x: 10; y: parent.height - 18; width: (parent.width - 20) * (1 - v.m.progress); height: 6; color: "#10180a"; opacity: 0.8 }
                Text { x: 10; y: 6; text: v.m.stateText; color: "#10180a"; font.pixelSize: 16; font.family: Theme.vtFamily }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter; y: lcd.y + lcd.height + 12; spacing: 14
                PlaySquare { fillColor: "#5c634a"; glyph: "#e7ecd0" }
                Dots { anchors.verticalCenter: parent.verticalCenter; selColor: "#a7b08a"; offColor: "#5a5e48" }
            }
            ModeRow { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 8
                selColor: "#a7b08a"; selText: "#10180a"; offText: "#a7b08a"; family: Theme.vtFamily; px: 16 }
        }
    }

    // 5. Focus terminal.
    Component {
        id: terminal
        Rectangle {
            radius: 12; color: "#cdd8b8"
            Rectangle { width: parent.width; height: 24; radius: 12; color: "#34472f"
                Rectangle { width: parent.width; height: 12; y: 12; color: "#34472f" }
                Text { x: 12; anchors.verticalCenter: parent.verticalCenter; text: "focus@notch:~$ timer"; color: "#cdd8b8"; font.pixelSize: 13; font.family: Theme.vtFamily } }
            Text { id: t1; anchors.horizontalCenter: parent.horizontalCenter; y: 48; text: v.m.timeText; color: "#34472f"; font.pixelSize: 62 * v.bigFont(); font.family: Theme.vtFamily }
            Text { anchors.horizontalCenter: parent.horizontalCenter; y: t1.y + t1.height - 4; color: "#34472f"; font.pixelSize: 18; font.family: Theme.vtFamily
                text: "[" + "#".repeat(Math.round(v.m.progress * 12)) + ".".repeat(12 - Math.round(v.m.progress * 12)) + "] " + v.m.stateText }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter; y: t1.y + t1.height + 28; spacing: 14
                PlaySquare { fillColor: "#34472f"; glyph: "#cdd8b8" }
                Dots { anchors.verticalCenter: parent.verticalCenter; selColor: "#34472f"; offColor: "#9cab88" }
            }
            ModeRow { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 8
                selColor: "#34472f"; selText: "#cdd8b8"; offText: "#34472f"; family: Theme.vtFamily; px: 16 }
        }
    }

    // 6. Zen: a slow breathing disc, hairline time.
    Component {
        id: zen
        Rectangle {
            radius: 16; color: "#131a16"
            Rectangle {
                id: disc; anchors.horizontalCenter: parent.horizontalCenter; y: 14; width: 140 * v.bigFont(); height: width; radius: width / 2
                color: "#1b2821"; border.color: "#365c45"; border.width: 1
                scale: 1
                SequentialAnimation on scale {
                    running: v.m.running && !v.app.cfg.reduceMotion; loops: Animation.Infinite
                    NumberAnimation { to: 1.06; duration: 4000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 4000; easing.type: Easing.InOutSine }
                }
                Rectangle { anchors.centerIn: parent; width: parent.width * (0.25 + 0.75 * (1 - v.m.progress)); height: width; radius: width / 2; color: "#24372b"; opacity: 0.8
                    Behavior on width { NumberAnimation { duration: 600 } } }
                Text { anchors.centerIn: parent; text: v.m.timeText; color: "#e8f0ea"; font.pixelSize: 32 * v.bigFont(); font.family: Theme.sans; font.weight: Font.Light }
            }
            Text { anchors.horizontalCenter: parent.horizontalCenter; y: disc.y + disc.height + 8; text: v.m.stateText.toLowerCase(); color: "#6e8d7d"; font.pixelSize: 11; font.family: Theme.sans; font.letterSpacing: 2 }
            ModeRow { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 8
                selColor: "#365c45"; selText: "#e8f0ea"; offText: "#6e8d7d" }
            MouseArea { anchors.fill: disc; onClicked: v.m.toggle() }
        }
    }

    // 7. Cyber HUD: FUEL bar, TACH arc, gear "R", big MPH-style readout.
    Component {
        id: cyber
        Rectangle {
            radius: 16; color: "#080c0b"; border.color: "#1d79b8"; border.width: 1
            Ring { id: tach; width: 150 * v.bigFont(); height: width; anchors.horizontalCenter: parent.horizontalCenter; y: 14
                progress: v.m.progress; fill: "#16a4df"; track: "#17241b"; stroke: 6 }
            Text { x: 14; y: 14; text: "FUEL"; color: Theme.warn; font.pixelSize: 9; font.family: Theme.monoFamily }
            Rectangle { x: 14; y: 28; width: 6; height: 90; radius: 3; color: "#17241b"
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: parent.height * (1 - v.m.progress); radius: 3; color: Theme.warn } }
            Text { anchors.right: parent.right; anchors.rightMargin: 14; y: 14; text: "R"; color: Theme.phos; font.pixelSize: 16; font.family: Theme.monoFamily; font.weight: Font.Bold }
            Text { anchors.right: parent.right; anchors.rightMargin: 14; y: 36; text: "TACH"; color: "#16a4df"; font.pixelSize: 9; font.family: Theme.monoFamily }
            Column {
                anchors.centerIn: tach; spacing: 0
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: v.m.timeText; color: "#e6fff4"; font.pixelSize: 28 * v.bigFont(); font.family: Theme.monoFamily; font.weight: Font.Bold }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "MPH"; color: Theme.dim; font.pixelSize: 9; font.family: Theme.monoFamily }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "SESSION " + v.m.session + " · " + v.m.stateText; color: Theme.phos; font.pixelSize: 8; font.family: Theme.monoFamily }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter; y: tach.y + tach.height + 8; spacing: 14
                PlaySquare { fillColor: Theme.phosDim; glyph: Theme.phos }
                Minutes { anchors.verticalCenter: parent.verticalCenter; family: Theme.monoFamily }
            }
            ModeRow { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 8
                selColor: "#16a4df"; selText: "#04141c"; family: Theme.monoFamily; px: 11 }
        }
    }
}
