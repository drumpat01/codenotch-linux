import QtQuick

Rectangle {
    id: b
    property string label
    property bool primary: false
    property color fg: "#fff"
    property color accent: "#7aa2f7"
    property color surface: "#222"
    signal clicked()
    implicitWidth: Math.max(30, txt.implicitWidth + 18)
    implicitHeight: 28
    radius: 8
    color: primary ? accent : surface
    opacity: ma.containsMouse ? 0.85 : 1
    Text {
        id: txt
        anchors.centerIn: parent
        text: b.label
        color: b.primary ? "#101114" : b.fg
        font.pixelSize: 13
    }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: b.clicked() }
}
