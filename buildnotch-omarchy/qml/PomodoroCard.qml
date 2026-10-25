import QtQuick

// Focus timer card. Drag the title out of the notch (or press the pop-out button) to float it on the desktop.
Card {
    id: root
    required property var app
    width: 280
    fill1: app.cfg.pomoStyle === "pixel" ? "#211a2c" : Qt.rgba(0.031, 0.039, 0.047, 0.97)
    fill2: app.cfg.pomoStyle === "pixel" ? "#100c17" : Qt.rgba(0.067, 0.078, 0.09, 0.96)

    Item {
        id: head
        width: parent.width; height: 24
        Text { anchors.verticalCenter: parent.verticalCenter; text: "Deep Focus"; color: "#fff"; font.pixelSize: 13; font.family: Theme.sans; font.weight: Font.DemiBold }
        Text {
            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
            text: "⇱"; color: Theme.dim; font.pixelSize: 15
            MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: root.app.timerPoppedOut = true }
        }
        MouseArea {
            width: parent.width - 30; height: parent.height
            property real sy: 0
            onPressed: mouse => sy = mouse.y
            onPositionChanged: mouse => { if (pressed && mouse.y - sy > 60) { root.app.timerPoppedOut = true; sy = 1e9; } }
        }
    }
    PomodoroView { y: head.height + 6; width: parent.width; height: parent.height - head.height - 6; app: root.app }
}
