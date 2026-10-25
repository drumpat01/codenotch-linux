import QtQuick
import Quickshell.Io
import "Lib.js" as Lib

// Contribution graph through `gh api graphql`, using the user's existing gh login. No token is read or stored here.
Item {
    id: g
    property int refreshMinutes: 30
    property var result: null
    property string error: ""
    property bool loading: false

    function refresh() { if (!gh.running) { loading = true; gh.running = true; } }
    Component.onCompleted: refresh()
    Timer { interval: Math.max(5, g.refreshMinutes) * 60000; running: true; repeat: true; onTriggered: g.refresh() }

    Process {
        id: gh
        command: ["gh", "api", "graphql", "-f", "query=" + Lib.CONTRIB_QUERY]
        stdout: StdioCollector { id: out }
        stderr: StdioCollector { id: err }
        onExited: code => {
            g.loading = false;
            if (code !== 0) { g.error = (err.text || "gh failed").trim().split("\n")[0] + " (run `gh auth login`)"; return; }
            try { g.result = Lib.parseContributions(out.text, 18); g.error = ""; }
            catch (e) { g.error = String(e); }
        }
    }
}
