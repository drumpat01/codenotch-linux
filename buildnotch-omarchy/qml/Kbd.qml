import QtQuick

// Key chip + caption used by the hotkey hint bar.
Row {
    id: kb
    property string keys: ""
    property string caption: ""
    spacing: 8
    Rectangle {
        height: 22; width: k.implicitWidth + 16; radius: 5
        color: Qt.rgba(1, 1, 1, 0.05); border.color: Theme.hair2; border.width: 1
        Text { id: k; anchors.centerIn: parent; text: kb.keys; color: Theme.dim; font.pixelSize: 10; font.family: Theme.monoFamily }
    }
    Text { anchors.verticalCenter: parent.verticalCenter; text: kb.caption; color: Theme.faint; font.pixelSize: 10; font.family: Theme.monoFamily }
}
