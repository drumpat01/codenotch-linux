import QtQuick

// Pill / square button. `active` paints the white (or accent) selected state used across the site.
Rectangle {
    id: b
    property string label: ""
    property bool active: false
    property color activeColor: "#ffffff"
    property color activeText: "#0a0b0d"
    property color idleColor: Qt.rgba(1, 1, 1, 0.06)
    property color idleText: Theme.text
    property int pixelSize: 12
    property string family: Theme.sans
    property bool bold: true
    signal clicked()

    implicitWidth: txt.implicitWidth + 24
    implicitHeight: 30
    radius: height / 2
    color: active ? activeColor : (mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : idleColor)
    opacity: enabled ? 1 : 0.4
    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        id: txt
        anchors.centerIn: parent
        text: b.label
        color: b.active ? b.activeText : b.idleText
        font.pixelSize: b.pixelSize
        font.family: b.family
        font.weight: b.bold ? Font.DemiBold : Font.Normal
    }
    MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: b.clicked() }
}
