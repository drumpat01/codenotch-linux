import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    required property var cfg
    required property var store
    readonly property var c: cfg.colors
    property int sel: 0
    readonly property var project: store.data.projects[Math.min(sel, store.data.projects.length - 1)]
    spacing: 14

    ColumnLayout {
        Layout.preferredWidth: 300
        Layout.fillHeight: true
        spacing: 8
        Flow {
            Layout.fillWidth: true
            spacing: 6
            Repeater {
                model: root.store.data.projects
                delegate: Btn {
                    required property var modelData
                    required property int index
                    label: modelData.name
                    primary: index === root.sel; accent: c.accent; fg: c.fg; surface: c.surface
                    onClicked: root.sel = index
                }
            }
        }
        Field {
            Layout.fillWidth: true
            fg: c.fg; surface: c.surface; accent: c.accent
            placeholderText: "New project… (Enter)"
            onAccepted: {
                const name = text.trim();
                if (!name) return;
                root.store.mutate(d => d.projects.push({ name: name, tasks: [] }));
                root.sel = root.store.data.projects.length - 1;
                text = "";
            }
        }
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: root.project ? root.project.tasks : []
            delegate: RowLayout {
                required property var modelData
                required property int index
                width: ListView.view.width
                CheckBox {
                    checked: modelData.done
                    onToggled: root.store.mutate(d => { d.projects[root.sel].tasks[index].done = checked; })
                }
                Text {
                    Layout.fillWidth: true
                    text: modelData.text
                    elide: Text.ElideRight
                    color: modelData.done ? c.dim : c.fg
                    font.strikeout: modelData.done
                    font.pixelSize: 13
                }
                Text {
                    text: "✕"; color: c.dim; font.pixelSize: 13
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.store.mutate(d => d.projects[root.sel].tasks.splice(index, 1)) }
                }
            }
        }
        Field {
            Layout.fillWidth: true
            fg: c.fg; surface: c.surface; accent: c.accent
            placeholderText: "Add task… (Enter)"
            onAccepted: {
                const t = text.trim();
                if (!t) return;
                root.store.mutate(d => d.projects[root.sel].tasks.push({ text: t, done: false }));
                text = "";
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Text { text: "Quick note"; color: c.dim; font.pixelSize: 12 }
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            TextArea {
                text: root.store.data.note
                color: c.fg
                font.pixelSize: 13
                wrapMode: TextEdit.Wrap
                selectionColor: c.accent
                background: Rectangle { radius: 8; color: c.surface }
                onTextChanged: if (text !== root.store.data.note) root.store.setNote(text)
            }
        }
    }
}
