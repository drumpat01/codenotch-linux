import QtQuick
import Quickshell
import Quickshell.Io
import "Lib.js" as Lib

// CPU / RAM / NET / battery for the top bar. Polls only while `active`.
Item {
    id: s
    property bool active: false
    property var v: ({ cpu: 0, ramUsed: 0, ramTotal: 0, net: 0, bat: -1, charging: false })
    property var _prev: null
    property double _at: 0

    Process {
        id: proc
        command: ["sh", Quickshell.shellPath("scripts/sysstat.sh")]
        stdout: StdioCollector {
            onStreamFinished: {
                var now = Date.now();
                s.v = Lib.parseSys(text, s._prev, (now - s._at) / 1000);
                s._prev = s.v; s._at = now;
            }
        }
    }
    Timer {
        interval: 2000; repeat: true; triggeredOnStart: true; running: s.active
        onTriggered: if (!proc.running) proc.running = true
    }
}
