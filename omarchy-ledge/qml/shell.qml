//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import "Lib.js" as Lib

ShellRoot {
    id: root
    readonly property string home: Quickshell.env("HOME")
    readonly property string cfgDir: (Quickshell.env("XDG_CONFIG_HOME") || home + "/.config") + "/ledge"
    readonly property string dataDir: (Quickshell.env("XDG_DATA_HOME") || home + "/.local/share") + "/ledge"

    property var cfg: Lib.merge(Lib.DEFAULTS, null)

    FileView {
        path: root.cfgDir + "/config.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.cfg = Lib.parseConfig(text())
    }

    Process { running: true; command: ["mkdir", "-p", root.cfgDir, root.dataDir] }

    Store { id: store; path: root.dataDir + "/data.json" }

    TimerModel {
        id: timer
        lengthSec: Math.round(root.cfg.timerMinutes * 60)
    }

    PopOut { id: popOut; visible: false; timer: timer; cfg: root.cfg }

    Variants {
        model: Quickshell.screens
        Notch {
            required property var modelData
            screen: modelData
            visible: root.cfg.monitor === "" || modelData.name === root.cfg.monitor
            cfg: root.cfg
            store: store
            timer: timer
            onPopOutTimer: popOut.visible = true
        }
    }
}
