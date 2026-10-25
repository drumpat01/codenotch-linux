import QtQuick
import Quickshell
import Quickshell.Io
import "Lib.js" as Lib

// Clipboard history from cliphist (needs the watcher `wl-paste --watch cliphist store`; the launcher and install.sh start it).
Item {
    id: c
    property bool active: false
    property var items: []
    property string error: ""
    readonly property string script: Quickshell.shellPath("scripts/clip.sh")

    function refresh() { if (!lister.running) lister.running = true; }
    function copy(id) { run(["copy", id]); app.pushNotice("Copied to clipboard"); }
    function remove(id) { run(["delete", id]); items = items.filter(function (i) { return i.id !== id; }); }
    function run(args) { var p = job.createObject(c, { args: args }); p.running = true; }
    required property var app

    onActiveChanged: if (active) refresh()
    Timer { interval: 3000; repeat: true; running: c.active; onTriggered: c.refresh() }

    Component {
        id: job
        Process {
            property var args
            command: ["sh", c.script].concat(args)
            onExited: destroy()
        }
    }
    Process {
        id: lister
        command: ["sh", c.script, "list"]
        stdout: StdioCollector { id: so }
        stderr: StdioCollector { id: se }
        onExited: code => {
            if (code === 127) { c.error = "cliphist is not installed. Install cliphist and wl-clipboard."; return; }
            if (code === 3) { c.error = "Clipboard watcher not running. Start it with: wl-paste --watch cliphist store"; return; }
            if (code !== 0) { c.error = "cliphist failed (exit " + code + ")."; return; }
            c.error = "";
            var now = Date.now(), old = {};
            c.items.forEach(function (i) { old[i.id] = i.seen; });
            c.items = Lib.parseCliphist(so.text).slice(0, 60).map(function (i) {
                i.seen = old[i.id] || now; return i;
            });
        }
    }
}
