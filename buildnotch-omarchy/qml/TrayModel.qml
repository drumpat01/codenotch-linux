import QtQuick
import Quickshell
import Quickshell.Io

// Temporary file tray: copies live in ~/.local/share/buildnotch/tray. Removing a copy never touches the original.
Item {
    id: t
    required property string dir
    property var files: []    // [{ name, path }]

    function refresh() { if (!lister.running) lister.running = true; }
    function add(urls) {
        for (var i = 0; i < urls.length; i++) {
            var p = String(urls[i]).replace(/^file:\/\//, "");
            run(["cp", "-r", "--", decodeURIComponent(p), dir + "/"]);
        }
        settle.restart();
    }
    function remove(path) { if (path.indexOf(dir + "/") === 0) { run(["rm", "-rf", "--", path]); settle.restart(); } }
    function run(cmd) { var p = job.createObject(t, { cmd: cmd }); p.running = true; }

    Component.onCompleted: { run(["mkdir", "-p", dir]); settle.restart(); }
    Timer { id: settle; interval: 400; onTriggered: t.refresh() }
    Component { id: job; Process { property var cmd; command: cmd; onExited: destroy() } }
    Process {
        id: lister
        command: ["find", t.dir, "-mindepth", "1", "-maxdepth", "1", "-printf", "%f\\n"]
        stdout: StdioCollector {
            onStreamFinished: t.files = text.split("\n").filter(function (n) { return n; }).sort()
                .map(function (n) { return { name: n, path: t.dir + "/" + n }; })
        }
    }
}
