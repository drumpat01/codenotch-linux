import QtQuick
import Quickshell
import "Lib.js" as Lib

// Code playground (autosaved) and Developer tools, Format (JSON pretty-print / minify).
DrawerBase {
    id: d
    required property var app
    title: tab === "code" ? "Code playground" : "Developer tools"
    property string tab: "code"
    readonly property var langs: ["JavaScript", "TypeScript", "Rust", "Python", "Plain text"]
    property string jsonError: ""

    function copy(text) { Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | wl-copy", "_", text]); app.pushNotice("Copied to clipboard"); }

    headerExtra: Row { spacing: 6
        Btn { label: "Code"; active: d.tab === "code"; pixelSize: 11; implicitHeight: 26; onClicked: d.tab = "code" }
        Btn { label: "Format"; active: d.tab === "json"; pixelSize: 11; implicitHeight: 26; onClicked: d.tab = "json" }
    }

    // ---- Code ----
    Item {
        anchors.fill: parent; visible: d.tab === "code"
        Row { id: bar; spacing: 6; height: 28
            Repeater { model: d.langs
                delegate: Btn { required property string modelData; label: modelData; pixelSize: 11; implicitHeight: 26; active: d.app.db.playground.lang === modelData
                    onClicked: d.app.dataStore.mutate(function (x) { x.playground.lang = modelData; }) } }
        }
        Rectangle {
            id: pane; y: bar.height + 6; width: parent.width; height: parent.height - y - 30; radius: 12
            color: Qt.rgba(0, 0, 0, 0.35); border.color: Theme.hair; border.width: 1
            Flickable {
                anchors.fill: parent; anchors.margins: 10; clip: true; contentHeight: Math.max(code.implicitHeight, height); boundsBehavior: Flickable.StopAtBounds
                Text { id: nums; width: 28; horizontalAlignment: Text.AlignRight; color: Theme.faint; font.pixelSize: 12; font.family: Theme.monoFamily
                    text: Array.from({ length: Math.max(code.lineCount, 6) }, function (_, i) { return i + 1; }).join("\n") }
                TextEdit { id: code; x: 40; width: parent.width - 40; wrapMode: TextEdit.NoWrap; selectByMouse: true
                    color: Theme.text; font.pixelSize: 12; font.family: Theme.monoFamily; tabStopDistance: 28
                    text: d.app.db.playground.code
                    onTextChanged: if (activeFocus) save.restart() }
            }
        }
        Timer { id: save; interval: 500; onTriggered: d.app.dataStore.mutate(function (x) { x.playground.code = code.text; }) }
        Row { anchors.bottom: parent.bottom; width: parent.width; spacing: 8
            Text { width: parent.width - 150; anchors.verticalCenter: parent.verticalCenter; text: "Saved locally as you type"; color: Theme.faint; font.pixelSize: 10; font.family: Theme.monoFamily }
            Btn { label: "Copy"; pixelSize: 11; implicitHeight: 26; onClicked: d.copy(code.text) }
            Btn { label: "Clear"; pixelSize: 11; implicitHeight: 26; onClicked: { code.text = ""; d.app.dataStore.mutate(function (x) { x.playground.code = ""; }); } }
        }
    }

    // ---- JSON format ----
    Item {
        anchors.fill: parent; visible: d.tab === "json"
        Row { id: jbar; spacing: 6; height: 28
            Btn { label: "Pretty-print"; active: true; activeColor: Theme.phos; activeText: "#04140c"; pixelSize: 11; implicitHeight: 26; onClicked: d.run("pretty") }
            Btn { label: "Minify"; pixelSize: 11; implicitHeight: 26; onClicked: d.run("minify") }
            Btn { label: "Copy result"; pixelSize: 11; implicitHeight: 26; enabled: out.text !== ""; onClicked: d.copy(out.text) }
            Btn { label: "Clear"; pixelSize: 11; implicitHeight: 26; onClicked: { inp.text = ""; out.text = ""; d.jsonError = ""; } }
            Text { anchors.verticalCenter: parent.verticalCenter; text: d.jsonError; color: Theme.bad; font.pixelSize: 11; font.family: Theme.sans }
        }
        Row { y: jbar.height + 6; width: parent.width; height: parent.height - y; spacing: 10
            Rectangle { width: (parent.width - 10) / 2; height: parent.height; radius: 12; color: Qt.rgba(0, 0, 0, 0.35); border.color: Theme.hair; border.width: 1
                Flickable { anchors.fill: parent; anchors.margins: 10; clip: true; contentHeight: inp.implicitHeight
                    TextEdit { id: inp; width: parent.width; wrapMode: TextEdit.WrapAnywhere; selectByMouse: true; color: Theme.text; font.pixelSize: 12; font.family: Theme.monoFamily
                        Text { visible: !inp.text && !inp.activeFocus; text: "Paste JSON here"; color: Theme.faint; font: inp.font } } } }
            Rectangle { width: (parent.width - 10) / 2; height: parent.height; radius: 12; color: Qt.rgba(0, 0, 0, 0.35); border.color: Theme.hair; border.width: 1
                Flickable { anchors.fill: parent; anchors.margins: 10; clip: true; contentHeight: out.implicitHeight
                    TextEdit { id: out; width: parent.width; wrapMode: TextEdit.WrapAnywhere; readOnly: true; selectByMouse: true; color: Theme.phos; font.pixelSize: 12; font.family: Theme.monoFamily } } }
        }
    }
    function run(mode) {
        var r = Lib.formatJson(inp.text, mode);
        out.text = r.ok ? r.text : "";
        jsonError = r.ok ? "" : r.error;
    }
}
