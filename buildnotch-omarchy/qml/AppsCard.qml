import QtQuick
import Quickshell

// Favorite apps: launch the apps you live in. Add from the installed list in Settings, or type a command.
Card {
    id: root
    required property var app
    width: 280
    readonly property var favs: app.cfg.favorites

    function launch(f) {
        if (f.id) app.apps.launchDesktop(f.id);
        else if (f.command) Quickshell.execDetached(["sh", "-c", f.command]);
    }
    function iconFor(f) {
        if (!f.id) return "";
        var es = app.apps.entries;
        for (var i = 0; i < es.length; i++) if (es[i].id === f.id) return es[i].icon;
        return "";
    }

    Text { text: "Favorite apps"; color: "#fff"; font.pixelSize: 13; font.family: Theme.sans; font.weight: Font.DemiBold }
    Grid {
        id: grid; y: 32; width: parent.width; columns: 3; rowSpacing: 10; columnSpacing: 10
        Repeater {
            model: root.favs
            delegate: Item {
                required property var modelData
                width: (grid.width - 20) / 3; height: 84
                Rectangle {
                    id: tile; anchors.horizontalCenter: parent.horizontalCenter; width: 54; height: 54; radius: 14
                    color: Qt.rgba(1, 1, 1, 0.05); border.color: Theme.hair; border.width: 1
                    Image { id: ic; anchors.centerIn: parent; width: 32; height: 32; smooth: true
                        source: root.iconFor(modelData) ? Quickshell.iconPath(root.iconFor(modelData), true) : ""; visible: status === Image.Ready }
                    Text { anchors.centerIn: parent; visible: ic.status !== Image.Ready; text: modelData.name.charAt(0); color: "#fff"; font.pixelSize: 20; font.family: Theme.sans; font.weight: Font.Bold }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.launch(modelData) }
                }
                Text { y: tile.height + 5; width: parent.width; elide: Text.ElideRight; horizontalAlignment: Text.AlignHCenter; text: modelData.name; color: Theme.dim; font.pixelSize: 10; font.family: Theme.sans }
            }
        }
        Item {
            width: (grid.width - 20) / 3; height: 84
            Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 54; height: 54; radius: 14; color: "transparent"; border.color: Theme.hair2; border.width: 1
                Text { anchors.centerIn: parent; text: "+"; color: Theme.dim; font.pixelSize: 22 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.app.openSettings("apps") } }
        }
    }
    Text { anchors.bottom: parent.bottom; text: "Launch the apps you live in."; color: Theme.faint; font.pixelSize: 10; font.family: Theme.sans }
}
