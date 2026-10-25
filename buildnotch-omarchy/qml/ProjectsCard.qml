import QtQuick
import "Lib.js" as Lib

// Projects with their tasks (grouped, with due dates and completion) and folder / site shortcuts.
Card {
    id: root
    required property var app
    width: 320
    readonly property var projects: app.db.projects
    readonly property int pi: app.db.project
    readonly property var proj: projects[pi]

    function mut(fn) { app.dataStore.mutate(function (d) { fn(d, d.projects[d.project]); }); }
    function addTask() {
        var t = newTask.text.trim();
        if (!t) return;
        var due = newDue.text.trim();
        mut(function (d, p) { p.tasks.push({ text: t, done: false, due: /^\d{4}-\d{2}-\d{2}$/.test(due) ? due : "" }); });
        newTask.text = ""; newDue.text = "";
    }
    function today() { return Qt.formatDate(new Date(), "yyyy-MM-dd"); }

    Row {
        id: head; width: parent.width; height: 26; spacing: 8
        Text { text: "Project:"; color: Theme.dim; font.pixelSize: 12; font.family: Theme.sans; anchors.verticalCenter: parent.verticalCenter }
        Text { text: root.proj.name; color: "#fff"; font.pixelSize: 14; font.family: Theme.sans; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 150; elide: Text.ElideRight }
        Btn { anchors.verticalCenter: parent.verticalCenter; label: "‹"; implicitWidth: 28; onClicked: root.app.setData("project", (root.pi + root.projects.length - 1) % root.projects.length) }
        Btn { anchors.verticalCenter: parent.verticalCenter; label: "›"; implicitWidth: 28; onClicked: root.app.setData("project", (root.pi + 1) % root.projects.length) }
        Btn { anchors.verticalCenter: parent.verticalCenter; label: "+"; implicitWidth: 28; onClicked: addProject.visible = !addProject.visible }
    }
    Field { id: addProject; visible: false; y: head.height + 4; width: parent.width; placeholder: "New project name, Enter to add"
        onAccepted: {
            var n = text.trim(); if (!n) return;
            root.app.dataStore.mutate(function (d) { d.projects.push({ name: n, path: "", url: "", tasks: [] }); d.project = d.projects.length - 1; });
            text = ""; visible = false;
        } }
    Row {
        id: links; y: head.height + (addProject.visible ? 38 : 6); spacing: 6; height: 24
        Btn { visible: root.proj.path !== ""; label: "Terminal"; pixelSize: 10; implicitHeight: 24
            onClicked: root.app.open(root.app.cfg.terminal.concat(["--", "sh", "-c", "cd -- \"$1\" && exec \"${SHELL:-sh}\"", "sh", Lib.expandHome(root.proj.path, root.app.home)])) }
        Btn { visible: root.proj.path !== ""; label: "Editor"; pixelSize: 10; implicitHeight: 24
            onClicked: root.app.open(root.app.cfg.terminal.concat(root.app.cfg.editor).concat([Lib.expandHome(root.proj.path, root.app.home)])) }
        Btn { visible: root.proj.path !== ""; label: "Folder"; pixelSize: 10; implicitHeight: 24
            onClicked: root.app.open(["xdg-open", Lib.expandHome(root.proj.path, root.app.home)]) }
        Btn { visible: root.proj.url !== ""; label: "Site"; pixelSize: 10; implicitHeight: 24; onClicked: root.app.open(["xdg-open", root.proj.url]) }
    }
    ListView {
        id: list
        y: links.y + (links.visible && (root.proj.path !== "" || root.proj.url !== "") ? 30 : 4)
        width: parent.width; height: parent.height - y - 66
        clip: true; spacing: 4; boundsBehavior: Flickable.StopAtBounds
        model: root.proj.tasks
        delegate: Rectangle {
            required property var modelData
            required property int index
            width: list.width; height: 34; radius: 10
            color: Qt.rgba(1, 1, 1, 0.04)
            Rectangle {
                x: 8; anchors.verticalCenter: parent.verticalCenter; width: 16; height: 16; radius: 5
                color: modelData.done ? Theme.phos : "transparent"; border.color: modelData.done ? Theme.phos : Theme.faint; border.width: 1.5
                Text { anchors.centerIn: parent; visible: modelData.done; text: "✓"; color: "#04140c"; font.pixelSize: 11; font.weight: Font.Bold }
                MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor
                    onClicked: root.mut(function (d, p) { p.tasks[index].done = !p.tasks[index].done; }) }
            }
            Text { x: 32; width: parent.width - 32 - (due.visible ? 70 : 0) - 28; anchors.verticalCenter: parent.verticalCenter; elide: Text.ElideRight
                text: modelData.text; color: modelData.done ? Theme.faint : Theme.text; font.pixelSize: 12; font.family: Theme.sans; font.strikeout: modelData.done }
            Text { id: due; visible: modelData.due !== ""; anchors.right: parent.right; anchors.rightMargin: 30; anchors.verticalCenter: parent.verticalCenter
                text: modelData.due; font.pixelSize: 9; font.family: Theme.monoFamily
                color: !modelData.done && modelData.due < root.today() ? Theme.bad : Theme.faint }
            Text { anchors.right: parent.right; anchors.rightMargin: 9; anchors.verticalCenter: parent.verticalCenter; text: "✕"; color: Theme.faint; font.pixelSize: 11
                MouseArea { anchors.fill: parent; anchors.margins: -5; cursorShape: Qt.PointingHandCursor
                    onClicked: root.mut(function (d, p) { p.tasks.splice(index, 1); }) } }
        }
        Text { anchors.centerIn: parent; visible: list.count === 0; text: "No tasks yet"; color: Theme.faint; font.pixelSize: 12; font.family: Theme.sans }
    }
    Column {
        anchors.bottom: parent.bottom; width: parent.width; spacing: 6
        Row { spacing: 6; width: parent.width
            Field { id: newTask; width: parent.width - 100 - 6; placeholder: "Next task"; onAccepted: root.addTask() }
            Field { id: newDue; width: 100; placeholder: "YYYY-MM-DD"; pixelSize: 10; onAccepted: root.addTask() } }
        Text { text: root.proj.tasks.filter(function (t) { return t.done; }).length + " of " + root.proj.tasks.length + " done"; color: Theme.faint; font.pixelSize: 10; font.family: Theme.monoFamily }
    }
}
