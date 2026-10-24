import QtQuick

Rectangle {
    property bool shown: false
    property alias text: label.text
    visible: shown
    z: 100
    x: -width / 2 + 4; y: -height - 4
    width: label.implicitWidth + 12; height: label.implicitHeight + 8
    radius: 6; color: "#000000"
    Text { id: label; anchors.centerIn: parent; color: "#fff"; font.pixelSize: 11 }
}
