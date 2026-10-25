import QtQuick
import Quickshell.Io
import "Lib.js" as Lib

// AI usage per provider. A provider is "available" only when its configured command prints usage JSON
// (see README); otherwise it is marked unavailable instead of showing a fake 0%.
Item {
    id: u
    required property var app
    // [{ id, name, ok, plan, windows: [{label, used, resetsAt}], at, error }]
    property var readings: []
    readonly property var providers: app.cfg.usage.providers.filter(function (p) { return p.enabled; })

    function refresh() {
        readings = providers.map(function (p) {
            var old = readings.filter(function (r) { return r.id === p.id; })[0];
            return old ? old : { id: p.id, name: p.name, ok: false, plan: "", windows: [], at: 0, error: p.command ? "Loading" : "Not connected" };
        });
        for (var i = 0; i < providers.length; i++) if (providers[i].command) run(providers[i]);
    }
    function run(p) {
        var proc = runner.createObject(u, { pid: p.id, pname: p.name, cmd: p.command });
        proc.running = true;
    }
    function put(id, patch) {
        readings = readings.map(function (r) { return r.id === id ? Object.assign({}, r, patch) : r; });
    }

    Component {
        id: runner
        Process {
            id: pr
            property string pid
            property string pname
            property string cmd
            command: ["sh", "-c", cmd]
            stdout: StdioCollector { id: so }
            onExited: code => {
                try {
                    if (code !== 0) throw new Error("command failed");
                    var r = Lib.parseUsage(so.text);
                    u.put(pid, { ok: true, plan: r.plan, windows: r.windows, at: Date.now(), error: "" });
                } catch (e) { u.put(pid, { ok: false, error: "Unavailable" }); }
                pr.destroy();
            }
        }
    }

    Connections { target: u.app.cfgStore; function onValueChanged() { u.refresh(); } }
    Component.onCompleted: refresh()
    Timer { interval: Math.max(1, u.app.cfg.usage.refreshMinutes) * 60000; repeat: true; running: true; onTriggered: u.refresh() }
}
