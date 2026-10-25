import QtQuick
import "Lib.js" as Lib

// Settings: General, Appearance (timer style, widgets, wallpaper), Fullscreen apps, AI, Apps.
DrawerBase {
    id: d
    required property var app
    title: "Settings"
    readonly property var cfg: app.cfg
    readonly property var styles: [
        { k: "clean", l: "Clean" }, { k: "pixel", l: "Pixel dusk" }, { k: "dots", l: "Dots" }, { k: "retro", l: "Retro clock" },
        { k: "terminal", l: "Focus terminal" }, { k: "zen", l: "Zen" }, { k: "cyber", l: "Cyber HUD" }]
    readonly property var names: ({ music: "Music", pomodoro: "Focus timer", ai: "AI apps", usage: "AI usage", github: "GitHub",
        projects: "Projects", quote: "Quote", apps: "Favorite apps", note: "Personal note" })

    component Section: Text { color: "#fff"; font.pixelSize: 13; font.family: Theme.sans; font.weight: Font.DemiBold }
    component Hint: Text { color: Theme.faint; font.pixelSize: 11; font.family: Theme.sans; wrapMode: Text.Wrap }
    component Toggle: Row {
        id: tg
        property string label: ""
        property bool checked: false
        signal flipped()
        spacing: 10; height: 24
        Rectangle { width: 38; height: 22; radius: 11; color: tg.checked ? Theme.phos : Qt.rgba(1, 1, 1, 0.14); anchors.verticalCenter: parent.verticalCenter
            Rectangle { y: 2; x: tg.checked ? 18 : 2; width: 18; height: 18; radius: 9; color: "#fff"; Behavior on x { NumberAnimation { duration: 120 } } }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: tg.flipped() } }
        Text { anchors.verticalCenter: parent.verticalCenter; text: tg.label; color: Theme.text; font.pixelSize: 12; font.family: Theme.sans }
    }

    Flickable {
        id: fl
        anchors.fill: parent; clip: true; contentWidth: width; contentHeight: cols.height; boundsBehavior: Flickable.StopAtBounds
        Component.onCompleted: if (d.app.settingsTab) { d.app.settingsTab = ""; }

        Row {
            id: cols; width: parent.width; spacing: 28
            // ---- column 1: General + Appearance ----
            Column { width: (parent.width - 56) / 3; spacing: 10
                Section { text: "General" }
                Toggle { label: "Open on hover"; checked: d.cfg.hoverOpen; onFlipped: d.app.setCfg("hoverOpen", !d.cfg.hoverOpen) }
                Hint { width: parent.width; text: "The bar opens when the pointer enters it. Click the bar to pin it open." }
                Toggle { label: "Short notch"; checked: d.cfg.shortNotch; onFlipped: d.app.setCfg("shortNotch", !d.cfg.shortNotch) }
                Toggle { label: "Reduce animation"; checked: d.cfg.reduceMotion; onFlipped: d.app.setCfg("reduceMotion", !d.cfg.reduceMotion) }
                Section { text: "Pomodoro style" }
                Hint { width: parent.width; text: "This changes every timer card. Pick the style here." }
                Flow { width: parent.width; spacing: 6
                    Repeater { model: d.styles
                        delegate: Btn { required property var modelData; label: modelData.l; pixelSize: 11; implicitHeight: 26; active: d.cfg.pomoStyle === modelData.k
                            onClicked: d.app.setCfg("pomoStyle", modelData.k) } } }
                Section { text: "Wallpaper" }
                Field { width: parent.width; placeholder: "/path/to/image.png (empty = none)"; text: d.cfg.wallpaper; onAccepted: d.app.setCfg("wallpaper", Lib.expandHome(text.trim(), d.app.home)) }
                Hint { width: parent.width; text: "Shown behind the expanded notch, dimmed so the controls stay readable. Press Enter to apply." }
            }
            // ---- column 2: widgets + fullscreen ----
            Column { width: (parent.width - 56) / 3; spacing: 10
                Section { text: "Widgets" }
                Hint { width: parent.width; text: "Show or hide dashboard cards. Hidden cards keep their position when you bring them back." }
                Repeater { model: d.cfg.widgets
                    delegate: Toggle { required property var modelData; label: d.names[modelData.id]; checked: modelData.visible
                        onFlipped: d.app.setCfg("widgets", d.cfg.widgets.map(function (w) { return w.id === modelData.id ? { id: w.id, visible: !w.visible } : w; })) } }
                Section { text: "Fullscreen apps" }
                Hint { width: parent.width; text: "The notch hides while one of these apps is fullscreen (Hyprland window class). Chrome is the default; other apps stay visible." }
                Repeater { model: d.cfg.hideFullscreen
                    delegate: Row { required property string modelData; spacing: 8; height: 22
                        Text { text: modelData; color: Theme.text; font.pixelSize: 12; font.family: Theme.monoFamily; anchors.verticalCenter: parent.verticalCenter; width: 180; elide: Text.ElideRight }
                        Text { text: "✕"; color: Theme.faint; anchors.verticalCenter: parent.verticalCenter
                            MouseArea { anchors.fill: parent; anchors.margins: -4; onClicked: d.app.setCfg("hideFullscreen", d.cfg.hideFullscreen.filter(function (c) { return c !== modelData; })) } } } }
                Field { width: parent.width; placeholder: "Add window class (hyprctl activewindow), Enter"
                    onAccepted: { var c = text.trim(); if (c && d.cfg.hideFullscreen.indexOf(c) < 0) d.app.setCfg("hideFullscreen", d.cfg.hideFullscreen.concat([c])); text = ""; } }
            }
            // ---- column 3: AI + apps ----
            Column { width: (parent.width - 56) / 3; spacing: 10
                Section { text: "AI usage providers" }
                Hint { width: parent.width; text: "Choose which providers appear. A usage command prints JSON: {\"plan\":\"Plus\",\"windows\":[{\"label\":\"5-hour limit\",\"usedPercent\":12,\"resetsAt\":\"2026-10-24T22:00:00Z\"}]}. Without one, the provider is shown as unavailable." }
                Repeater { model: d.cfg.usage.providers
                    delegate: Column { required property var modelData; required property int index; width: parent.width; spacing: 4
                        Toggle { label: modelData.name; checked: modelData.enabled
                            onFlipped: d.setProvider(index, { enabled: !modelData.enabled }) }
                        Field { width: parent.width; placeholder: "usage command"; text: modelData.command; pixelSize: 11
                            onAccepted: d.setProvider(index, { command: text.trim() }) } } }
                Section { text: "AI app shortcuts" }
                Hint { width: parent.width; text: "Installed AI apps are found automatically. Add your own: name | command" }
                Field { width: parent.width; placeholder: "Name | command, Enter to add"
                    onAccepted: { var p = text.split("|"); if (p.length === 2 && p[0].trim() && p[1].trim()) d.app.setCfg("customApps", d.cfg.customApps.concat([{ name: p[0].trim(), command: p[1].trim() }])); text = ""; } }
                Repeater { model: d.cfg.customApps
                    delegate: Row { required property var modelData; spacing: 8
                        Text { text: modelData.name; color: Theme.text; font.pixelSize: 12; font.family: Theme.sans; width: 190; elide: Text.ElideRight }
                        Text { text: "✕"; color: Theme.faint; MouseArea { anchors.fill: parent; anchors.margins: -4
                            onClicked: d.app.setCfg("customApps", d.cfg.customApps.filter(function (c) { return c !== modelData; })) } } } }
                Section { text: "Favorite apps" }
                Hint { width: parent.width; text: "Add a desktop app by name (e.g. Firefox) or a free command: Name | command" }
                Field { width: parent.width; placeholder: "App name or Name | command, Enter to add"; onAccepted: { d.addFavorite(text.trim()); text = ""; } }
                Repeater { model: d.cfg.favorites
                    delegate: Row { required property var modelData; spacing: 8
                        Text { text: modelData.name; color: Theme.text; font.pixelSize: 12; font.family: Theme.sans; width: 190; elide: Text.ElideRight }
                        Text { text: "✕"; color: Theme.faint; MouseArea { anchors.fill: parent; anchors.margins: -4
                            onClicked: d.app.setCfg("favorites", d.cfg.favorites.filter(function (c) { return c !== modelData; })) } } } }
            }
        }
    }

    function setProvider(i, patch) {
        var list = cfg.usage.providers.map(function (p, j) { return j === i ? Object.assign({}, p, patch) : p; });
        app.cfgStore.mutate(function (c) { c.usage.providers = list; });
    }
    function addFavorite(t) {
        if (!t) return;
        var entry = null;
        if (t.indexOf("|") > 0) {
            var p = t.split("|");
            entry = { name: p[0].trim(), id: "", command: p[1].trim() };
        } else {
            var es = app.apps.entries, q = t.toLowerCase();
            for (var i = 0; i < es.length; i++) if (es[i].name.toLowerCase().indexOf(q) >= 0) { entry = { name: es[i].name, id: es[i].id, command: "" }; break; }
        }
        if (entry && entry.name) app.setCfg("favorites", cfg.favorites.concat([entry]));
    }
}
