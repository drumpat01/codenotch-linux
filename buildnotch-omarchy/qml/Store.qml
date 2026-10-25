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

    Timer { id: saveTimer; interval: 300; onTriggered: { s.writing = true; file.setText(JSON.stringify(s.value, null, 2)); } }
    property bool writing: false

    FileView {
        id: file
        path: s.path
        watchChanges: true
        onFileChanged: { if (s.writing) { s.writing = false; return; } reload(); }
        onLoaded: { s.value = s.normalize(Lib.parseJson(file.text())); s.loaded = true; }
        onLoadFailed: s.loaded = true
    }
}
