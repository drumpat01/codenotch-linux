import QtQuick
import Quickshell.Io
import "Lib.js" as Lib

// Tasks + quick note, persisted as JSON.
Item {
    id: s
    property string path
    property var data: Lib.normalizeData(null)

    function mutate(fn) {
        fn(data);
        data = JSON.parse(JSON.stringify(data));
        saveTimer.restart();
    }
    // The note is edited live, so avoid re-assigning `data` (would reset the editor).
    function setNote(text) {
        data.note = text;
        saveTimer.restart();
    }

    Timer { id: saveTimer; interval: 400; onTriggered: file.setText(JSON.stringify(s.data, null, 2)) }

    FileView {
        id: file
        path: s.path
        onLoaded: s.data = Lib.normalizeData((function () { try { return JSON.parse(file.text()); } catch (e) { return null; } })())
    }
}
