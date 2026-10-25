import QtQuick
import Quickshell
import "Lib.js" as Lib

// Installed AI apps (matched against known .desktop ids) and every launchable desktop app for pickers.
Item {
    id: a
    required property var app
    readonly property var entries: DesktopEntries.applications.values
    readonly property var ai: {
        var es = entries.map(function (e) { return { id: e.id, name: e.name }; });
        var matched = Lib.matchAiApps(es).map(function (m) {
            var e = entries[m.index];
            return { name: m.name, entry: e, icon: e.icon, command: "" };
        });
        app.cfg.customApps.forEach(function (c) { matched.push({ name: c.name, entry: null, icon: "", command: c.command }); });
        return matched;
    }

    function launch(item) {
        if (item.entry) item.entry.execute();
        else if (item.command) Quickshell.execDetached(["sh", "-c", item.command]);
    }
    function launchDesktop(id) {
        for (var i = 0; i < entries.length; i++) if (entries[i].id === id) { entries[i].execute(); return; }
    }
}
