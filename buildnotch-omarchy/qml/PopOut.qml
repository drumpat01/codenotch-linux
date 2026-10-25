import QtQuick
import Quickshell

// The focus timer, floated onto the desktop. Float it with the windowrule in hyprland.conf.
FloatingWindow {
    id: w
    required property var app
    title: "BuildNotch Timer"
    visible: app.timerPoppedOut
    implicitWidth: 300
    implicitHeight: 320
    color: "#0a0b0d"
    onVisibleChanged: if (!visible) app.timerPoppedOut = false

    Item {
        anchors.fill: parent; anchors.margins: 14
        Row { id: head; width: parent.width; height: 22
            Text { text: "Deep Focus"; color: "#fff"; font.pixelSize: 13; font.family: Theme.sans; font.weight: Font.DemiBold; width: parent.width - 80; anchors.verticalCenter: parent.verticalCenter }
            Text { text: "Dock"; color: Theme.dim; font.pixelSize: 11; font.family: Theme.sans; anchors.verticalCenter: parent.verticalCenter
                MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: w.app.timerPoppedOut = false } } }
        PomodoroView { y: head.height + 6; width: parent.width; height: parent.height - head.height - 6; app: w.app; compact: true }
    }
}
