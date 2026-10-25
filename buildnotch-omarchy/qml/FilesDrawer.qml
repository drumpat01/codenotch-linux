import QtQuick
import Quickshell

// File tray: drop files in, see names and thumbnails, drag them out or remove the tray copy.
DrawerBase {
    id: d
    required property var app
    title: "File tray"
    property bool over: false
    Component.onCompleted: app.tray.refresh()

    headerExtra: Row { spacing: 6
        Btn { label: "Open folder"; pixelSize: 11; implicitHeight: 26; onClicked: d.app.open(["xdg-open", d.app.tray.dir]) } }

    DropArea {
        anchors.fill: parent
        onEntered: d.over = true
        onExited: d.over = false
        onDropped: drop => { d.over = false; if (drop.hasUrls) d.app.tray.add(drop.urls); }
    }
    Rectangle { anchors.fill: parent; radius: 14; color: d.over ? Theme.phosDim : "transparent"; border.color: d.over ? Theme.phos : Theme.hair2; border.width: 1
        Behavior on color { ColorAnimation { duration: 120 } } }
    Text { anchors.centerIn: parent; visible: d.app.tray.files.length === 0; text: "Drop files here"; color: Theme.faint; font.pixelSize: 13; font.family: Theme.sans }

    Flickable {
        anchors.fill: parent; anchors.margins: 10; contentHeight: flow.height; clip: true; boundsBehavior: Flickable.StopAtBounds
        Flow {
            id: flow; width: parent.width; spacing: 10
            Repeater {
                model: d.app.tray.files
                delegate: Rectangle {
                    id: tile
                    required property var modelData
                    width: 120; height: 110; radius: 12; color: Qt.rgba(1, 1, 1, 0.04); border.color: Theme.hair; border.width: 1
                    readonly property bool isImg: /\.(png|jpe?g|gif|webp|bmp|svg)$/i.test(modelData.name)
                    Drag.dragType: Drag.Automatic
                    Drag.supportedActions: Qt.CopyAction
                    Drag.mimeData: { "text/uri-list": "file://" + modelData.path }
                    Image { visible: tile.isImg; x: 8; y: 8; width: parent.width - 16; height: 60; fillMode: Image.PreserveAspectCrop; asynchronous: true
                        sourceSize.width: 240; source: tile.isImg ? "file://" + modelData.path : "" }
                    Text { visible: !tile.isImg; x: 0; y: 14; width: parent.width; horizontalAlignment: Text.AlignHCenter; text: "▤"; color: Theme.dim; font.pixelSize: 36 }
                    Text { x: 8; y: 74; width: parent.width - 16; elide: Text.ElideMiddle; text: modelData.name; color: Theme.text; font.pixelSize: 10; font.family: Theme.sans }
                    Text { x: 8; y: 90; text: "Remove"; color: Theme.faint; font.pixelSize: 9; font.family: Theme.monoFamily
                        MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor; onClicked: d.app.tray.remove(modelData.path) } }
                    // Drag a tile out to another app: starts a real Wayland drag with a file URI.
                    DragHandler {
                        target: null
                        onActiveChanged: {
                            if (active) tile.grabToImage(function (r) { tile.Drag.imageSource = r.url; tile.Drag.active = true; });
                            else tile.Drag.active = false;
                        }
                    }
                }
            }
        }
    }
}
