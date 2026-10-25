import QtQuick
import Quickshell.Io
import "Lib.js" as Lib

// A JSON file that is loaded once, watched, and saved (debounced) after every change.
Item {
    id: s
    property string path
    property string kind: "cfg"       // "cfg" or "data": which Lib normalizer applies (a plain literal, so it is set before `data` first evaluates)
    function normalize(x) { return kind === "cfg" ? Lib.normalizeCfg(x) : Lib.normalizeData(x); }
    property var value: kind === "cfg" ? Lib.normalizeCfg(null) : Lib.normalizeData(null)
    property bool loaded: false
    property string lastWritten: ""   // the text this process last saved, to tell its own writes from outside edits

    function set(key, v) {
        var d = Lib.clone(value);
        d[key] = v;
        value = normalize(d);
        saveTimer.restart();
    }
    function mutate(fn) {
        var d = Lib.clone(value);
        fn(d);
        value = normalize(d);
        saveTimer.restart();
    }

    Timer { id: saveTimer; interval: 300; onTriggered: { s.lastWritten = JSON.stringify(s.value, null, 2); file.setText(s.lastWritten); } }

    FileView {
        id: file
        path: s.path
        watchChanges: true
        // Every change is re-read; onLoaded decides whether it is our own write or an outside edit.
        onFileChanged: reload()
        onLoaded: {
            var t = file.text();
            if (s.loaded && t === s.lastWritten) return;                 // echo of our own save
            var parsed = Lib.parseJson(t);
            if (s.loaded && (parsed === null || saveTimer.running)) return;  // half-written file, or our edit is still pending
            s.value = s.normalize(parsed);
            s.lastWritten = "";
            s.loaded = true;
        }
        onLoadFailed: s.loaded = true
    }
}
