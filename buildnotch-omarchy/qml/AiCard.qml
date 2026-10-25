import QtQuick
import Quickshell

// Installed AI apps found in the desktop database, plus your own shortcuts. ALT+1..6 launches the first six.
Card {
    id: root
    required property var app
    width: 280
    readonly property var items: app.apps.ai

    Item {
        id: head
        width: parent.width; height: 24
        Text { anchors.centerIn: parent; text: "AI"; color: "#fff"; font.pixelSize: 13; font.family: Theme.sans; font.weight: Font.DemiBold }
        Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: "◔"; color: Theme.dim; font.pixelSize: 15
            MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: root.app.openSettings("ai"); }
        }
    }
    Flickable {
        y: head.height + 8; width: parent.width; height: parent.height - head.height - 8 - 70
        contentHeight: grid.height; clip: true; boundsBehavior: Flickable.StopAtBounds
        Grid {
            id: grid
            width: parent.width; columns: 2; rowSpacing: 10; columnSpacing: 10
            Repeater {
                model: root.items
                delegate: Item {
                    required property var modelData
                    required property int index
                    width: (grid.width - 10) / 2; height: 96
                    Rectangle {
                        id: tile
                        anchors.horizontalCenter: parent.horizontalCenter; width: 60; height: 60; radius: 16
                        color: ma.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(1, 1, 1, 0.05)
                        border.color: Theme.hair; border.width: 1
                        Image {
                            id: appIcon
                            anchors.centerIn: parent; width: 36; height: 36; smooth: true
                            source: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""
                            visible: status === Image.Ready
                        }
                        Text { anchors.centerIn: parent; visible: !modelData.icon || appIcon.status !== Image.Ready
                            text: modelData.name.charAt(0); color: "#fff"; font.pixelSize: 24; font.family: Theme.sans; font.weight: Font.Bold }
                        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.app.apps.launch(modelData) }
                    }
                    Text { y: tile.height + 6; width: parent.width; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight
                        text: (index < 6 ? (index + 1) + "  " : "") + modelData.name; color: Theme.dim; font.pixelSize: 11; font.family: Theme.sans }
                }
            }
        }
    }
    Column {
        anchors.bottom: parent.bottom; width: parent.width; spacing: 8
        Text { anchors.horizontalCenter: parent.horizontalCenter; visible: root.items.length === 0; text: "No AI apps found"; color: Theme.faint; font.pixelSize: 11; font.family: Theme.sans }
        Btn { anchors.horizontalCenter: parent.horizontalCenter; label: "+  Add"; idleColor: "transparent"; onClicked: root.app.openSettings("ai") }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "ALT + 1 – 6 TO LAUNCH"; color: Theme.faint; font.pixelSize: 9; font.family: Theme.monoFamily }
    }
}
