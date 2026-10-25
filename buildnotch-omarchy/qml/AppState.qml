import QtQuick
import Quickshell

// Everything the notch, the cards and the floating timer share.
Item {
    id: root
    readonly property string home: Quickshell.env("HOME")
    readonly property string cfgDir: (Quickshell.env("XDG_CONFIG_HOME") || home + "/.config") + "/buildnotch"
    readonly property string dataDir: (Quickshell.env("XDG_DATA_HOME") || home + "/.local/share") + "/buildnotch"

    readonly property var cfgStore: _cfgStore
    readonly property var dataStore: _dataStore
    readonly property var cfg: _cfgStore.value
    readonly property var db: _dataStore.value
    readonly property var pomo: _pomo
    readonly property var sys: _sys
    readonly property var gh: _gh
    readonly property var usage: _usage
    readonly property var clipboard: _clipboard
    readonly property var tray: _tray
    readonly property var apps: _apps
    readonly property var fullscreen: _fs

    property var notices: []        // [{ text, at }] shown by the bell
    property int unread: 0
    property bool timerPoppedOut: false
    property int openCount: 0             // notches currently expanded; the system readout only polls while > 0
    signal toggleRequested()
    signal pageRequested(string page)
    property string page: "home"          // home | media | files | clipboard | playground | settings
    property string settingsTab: ""       // jumps Settings to a section (e.g. "ai")
    function pushNotice(text) { notices = [{ text: text, at: Date.now() }].concat(notices).slice(0, 20); unread += 1; }

    function openSettings(tab) { settingsTab = tab; page = "settings"; }
    function setCfg(key, value) { _cfgStore.set(key, value); }
    function setData(key, value) { _dataStore.set(key, value); }
    function open(cmd) { Quickshell.execDetached(cmd); }

    Store { id: _cfgStore; path: root.cfgDir + "/config.json"; kind: "cfg" }
    Store { id: _dataStore; path: root.dataDir + "/data.json"; kind: "data" }

    // Create the config on first run so there is a file to edit.
    Connections {
        target: _cfgStore
        function onLoadedChanged() { if (_cfgStore.loaded) _cfgStore.set("pomoStyle", _cfgStore.value.pomoStyle); }
    }
    Component.onCompleted: Quickshell.execDetached(["mkdir", "-p", cfgDir, dataDir])

    PomodoroModel { id: _pomo; app: root }
    SysStats { id: _sys; active: root.openCount > 0 }
    GitHubModel { id: _gh; refreshMinutes: root.cfg.githubRefreshMinutes }
    UsageModel { id: _usage; app: root }
    ClipModel { id: _clipboard; app: root }
    TrayModel { id: _tray; dir: root.dataDir + "/tray" }
    AppsModel { id: _apps; app: root }
    FullscreenWatcher { id: _fs; rules: root.cfg.hideFullscreen }
}
