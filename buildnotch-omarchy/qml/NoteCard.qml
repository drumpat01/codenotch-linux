import QtQuick
import "Lib.js" as Lib

// Personal note with a word count and a saved indicator. Written back to data.json as you type.
Card {
    id: root
    required property var app
    width: 300
    property bool dirty: false

    Row { id: head; width: parent.width; height: 24
        Text { text: "Personal note"; color: "#fff"; font.pixelSize: 13; font.family: Theme.sans; font.weight: Font.DemiBold; width: parent.width - 150; anchors.verticalCenter: parent.verticalCenter }
        Text { anchors.verticalCenter: parent.verticalCenter; width: 150; horizontalAlignment: Text.AlignRight; color: Theme.faint; font.pixelSize: 10; font.family: Theme.monoFamily
            text: "Today · " + Lib.wordCount(editor.text) + " words" }
    }
    Flickable {
        y: head.height + 8; width: parent.width; height: parent.height - head.height - 8 - 22
        contentHeight: editor.implicitHeight; clip: true; boundsBehavior: Flickable.StopAtBounds
        TextEdit {
            id: editor
            width: parent.width; wrapMode: TextEdit.Wrap; selectByMouse: true
            color: Theme.text; font.pixelSize: 13; font.family: Theme.sans
            text: root.app.db.note
            onTextChanged: if (activeFocus) { root.dirty = true; save.restart(); }
            Text { visible: !editor.text && !editor.activeFocus; text: "Write down your plan."; color: Theme.faint; font: editor.font }
        }
    }
    Timer { id: save; interval: 500
        onTriggered: { root.app.dataStore.mutate(function (d) { d.note = editor.text; d.noteSavedAt = Date.now(); }); root.dirty = false; } }
    Text { anchors.bottom: parent.bottom; color: root.dirty ? Theme.warn : Theme.phos; font.pixelSize: 10; font.family: Theme.monoFamily
        text: root.dirty ? "Saving…" : "Saved" }
}
