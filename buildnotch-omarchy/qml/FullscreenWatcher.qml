import QtQuick
import Quickshell.Io
import "Lib.js" as Lib

// Hides the notch while a fullscreen window from a configured app class is focused (Hyprland IPC).
Item {
    id: w
    property var rules: []
    property bool hidden: false

    Process {
        id: proc
        command: ["hyprctl", "activewindow", "-j"]
        stdout: StdioCollector { onStreamFinished: w.hidden = Lib.shouldHide(Lib.parseJson(text), w.rules) }
    }
    Timer { interval: 1000; repeat: true; running: true; onTriggered: if (!proc.running) proc.running = true }
}
