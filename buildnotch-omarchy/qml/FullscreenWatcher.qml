import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
import "Lib.js" as Lib

// Hides the notch while a fullscreen window from a configured app class is focused. Driven by Hyprland's
// event socket (Quickshell.Hyprland), so `hyprctl` runs only when focus or fullscreen state actually changes.
Item {
    id: w
    property var rules: []
    property bool hidden: false

    readonly property var watched: ["fullscreen", "activewindowv2", "workspacev2", "focusedmonv2", "closewindow", "movewindowv2"]

    Connections {
        target: Hyprland
        function onRawEvent(event) { if (w.watched.indexOf(event.name) >= 0) settle.restart(); }
    }
    onRulesChanged: settle.restart()
    Component.onCompleted: settle.restart()

    // Several events arrive per focus change; read the state once after they settle.
    Timer { id: settle; interval: 40; onTriggered: if (!proc.running) proc.running = true; else again.restart() }
    Timer { id: again; interval: 80; onTriggered: settle.restart() }

    Process {
        id: proc
        command: ["hyprctl", "activewindow", "-j"]
        stdout: StdioCollector { onStreamFinished: w.hidden = Lib.shouldHide(Lib.parseJson(text), w.rules) }
    }
}
