import QtQuick

// Small hover label for the heat grid.
Rectangle {
    property bool shown: false
    property alias text: t.text
    visible: shown
    z: 100
    x: -width / 2 + parent.width / 2; y: -height - 4
    width: t.implicitWidth + 12; height: 20; radius: 5
    color: Theme.glass2; border.color: Theme.hair2; border.width: 1
    Text { id: t; anchors.centerIn: parent; color: Theme.text; font.pixelSize: 10; font.family: Theme.sans }
}
