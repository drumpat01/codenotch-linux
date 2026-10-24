import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "Lib.js" as Lib

RowLayout {
    id: root
    required property var cfg
    readonly property var c: cfg.colors
    readonly property string home: Quickshell.env("HOME")
    spacing: 14

    Process { id: launcher }
    function run(cmd, dir) {
        launcher.workingDirectory = dir || home;
        launcher.command = cmd;
        launcher.running = true;
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredWidth: 3
        spacing: 8
        Field {
            id: search
            Layout.fillWidth: true
            fg: c.fg; surface: c.surface; accent: c.accent
            placeholderText: "Search apps…"
        }
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2
            model: ScriptModel {
                values: DesktopEntries.applications.values
                    .filter(e => !e.noDisplay && e.name.toLowerCase().includes(search.text.toLowerCase()))
                    .sort((a, b) => a.name.localeCompare(b.name))
            }
            delegate: Rectangle {
                required property var modelData
                width: ListView.view.width
                height: 32
                radius: 6
                color: ma.containsMouse ? c.surface : "transparent"
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 6; spacing: 8
                    Image { Layout.preferredWidth: 20; Layout.preferredHeight: 20; source: Quickshell.iconPath(modelData.icon, true); sourceSize: Qt.size(20, 20) }
                    Text { Layout.fillWidth: true; text: modelData.name; color: c.fg; font.pixelSize: 13; elide: Text.ElideRight }
                }
                MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: modelData.execute() }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredWidth: 2
        spacing: 6
        Text { text: "Projects"; color: c.dim; font.pixelSize: 12 }
        Text {
            visible: root.cfg.projects.length === 0
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: c.dim; font.pixelSize: 12
            text: "Add folders under \"projects\" in ~/.config/ledge/config.json"
        }
        Repeater {
            model: root.cfg.projects
            delegate: RowLayout {
                required property var modelData
                readonly property string dir: Lib.expandHome(modelData.path, root.home)
                Layout.fillWidth: true
                spacing: 6
                Text { Layout.fillWidth: true; text: modelData.name; color: c.fg; font.pixelSize: 13; elide: Text.ElideRight }
                Btn { label: "Term"; fg: c.fg; surface: c.surface; onClicked: root.run(root.cfg.terminal, dir) }
                Btn { label: "Edit"; fg: c.fg; surface: c.surface; onClicked: root.run(root.cfg.terminal.concat(root.cfg.editor), dir) }
            }
        }
        Item { Layout.fillHeight: true }
    }
}
