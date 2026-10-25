import QtQuick
import Quickshell.Io
import "Lib.js" as Lib

// Clipboard history: filters, wrapping grid, focused preview, copy, remove.
DrawerBase {
    id: d
    required property var app
    title: "Clipboard history"
    shortcut: "SUPER + V"
    property string filter: "All"
    property var open: null            // item being previewed
    property string fullText: ""
    readonly property var shown: app.clipboard.items.filter(function (i) { return Lib.clipMatches(i, d.filter); })

    Component.onCompleted: app.clipboard.active = true
    Component.onDestruction: app.clipboard.active = false

    headerExtra: Row {
        spacing: 6
        Repeater {
            model: ["All", "Text", "Code", "Images", "Links"]
            delegate: Btn { required property string modelData; label: modelData; active: d.filter === modelData; pixelSize: 11; implicitHeight: 26
                onClicked: { d.filter = modelData; d.open = null; } }
        }
    }

    Text { visible: d.app.clipboard.error !== ""; anchors.centerIn: parent; text: d.app.clipboard.error; color: Theme.bad; font.pixelSize: 12; font.family: Theme.sans }
    Text { visible: d.app.clipboard.error === "" && d.shown.length === 0; anchors.centerIn: parent; text: "Nothing copied yet"; color: Theme.faint; font.pixelSize: 12; font.family: Theme.sans }

    Flickable {
        id: fl
        anchors.fill: parent; visible: d.open === null
        contentWidth: width; contentHeight: grid.height; clip: true; boundsBehavior: Flickable.StopAtBounds
        Flow {
            id: grid; width: parent.width; spacing: 10
            Repeater {
                model: d.shown
                delegate: Rectangle {
                    required property var modelData
                    width: (grid.width - 30) / 4; height: 112; radius: 14
                    color: Qt.rgba(1, 1, 1, 0.035); border.color: hov.hovered ? Theme.hair2 : Theme.hair; border.width: 1
                    HoverHandler { id: hov }
                    TapHandler { onTapped: { d.open = modelData; d.loadFull(modelData); } }
                    Component.onCompleted: if (modelData.kind === "image") d.requestImg(modelData.id)
                    Text { x: 12; y: 10; text: modelData.kind.charAt(0).toUpperCase() + modelData.kind.slice(1); color: Theme.phos; font.pixelSize: 9; font.family: Theme.monoFamily }
                    Image { visible: modelData.kind === "image"; x: 12; y: 26; width: parent.width - 24; height: 52; fillMode: Image.PreserveAspectFit; horizontalAlignment: Image.AlignLeft
                        asynchronous: true; source: modelData.kind === "image" ? d.imgSource(modelData) : "" }
                    Text { visible: modelData.kind !== "image"; x: 12; y: 26; width: parent.width - 24; height: 52; wrapMode: Text.Wrap; elide: Text.ElideRight; maximumLineCount: 3
                        text: modelData.preview; color: Theme.text; font.pixelSize: 11; font.family: modelData.kind === "code" ? Theme.monoFamily : Theme.sans }
                    Text { x: 12; y: parent.height - 22; text: modelData.kind === "image" ? modelData.meta : Lib.relTime(modelData.seen); color: Theme.faint; font.pixelSize: 9; font.family: Theme.monoFamily }
                    Btn { anchors.right: parent.right; anchors.rightMargin: 8; y: parent.height - 30; label: "Copy"; pixelSize: 10; implicitHeight: 22
                        onClicked: d.app.clipboard.copy(modelData.id) }
                }
            }
        }
    }

    // Focused preview: copy it again or remove it. Images fit inside the preview.
    Rectangle {
        anchors.fill: parent; visible: d.open !== null; radius: 14
        color: Qt.rgba(1, 1, 1, 0.035); border.color: Theme.hair; border.width: 1
        Row { x: 12; y: 10; spacing: 8
            Btn { label: "‹ Back"; pixelSize: 11; implicitHeight: 26; onClicked: d.open = null }
            Btn { label: "Copy"; pixelSize: 11; implicitHeight: 26; active: true; activeColor: Theme.phos; activeText: "#04140c"; onClicked: d.app.clipboard.copy(d.open.id) }
            Btn { label: "Remove"; pixelSize: 11; implicitHeight: 26; idleText: Theme.bad; onClicked: { d.app.clipboard.remove(d.open.id); d.open = null; } }
        }
        Image { visible: d.open !== null && d.open.kind === "image"; x: 12; y: 46; width: parent.width - 24; height: parent.height - 58
            fillMode: Image.PreserveAspectFit; horizontalAlignment: Image.AlignLeft; asynchronous: true
            source: d.open && d.open.kind === "image" ? d.imgSource(d.open) : "" }
        Flickable { visible: d.open !== null && d.open.kind !== "image"; x: 12; y: 46; width: parent.width - 24; height: parent.height - 58
            contentHeight: full.implicitHeight; clip: true
            Text { id: full; width: parent.width; wrapMode: Text.Wrap; text: d.fullText; color: Theme.text; font.pixelSize: 12
                font.family: d.open && d.open.kind === "code" ? Theme.monoFamily : Theme.sans } }
    }

    // Images and full text are decoded on demand by scripts/clip.sh.
    property var imgPaths: ({})
    function imgSource(item) { return imgPaths[item.id] ? "file://" + imgPaths[item.id] : ""; }
    function requestImg(id) {
        if (pending[id]) return;
        pending[id] = true;
        var p = imgJob.createObject(d, { cid: id }); p.running = true;
    }
    property var pending: ({})
    function loadFull(item) {
        fullText = item.preview;
        if (item.kind === "image") return;
        var p = textJob.createObject(d, { cid: item.id }); p.running = true;
    }
    Component {
        id: imgJob
        Process {
            property string cid
            command: ["sh", d.app.clipboard.script, "image", cid]
            stdout: StdioCollector { id: so }
            onExited: code => { if (code === 0) { var m = d.imgPaths; m[cid] = so.text.trim(); d.imgPaths = Object.assign({}, m); } destroy(); }
        }
    }
    Component {
        id: textJob
        Process {
            property string cid
            command: ["sh", d.app.clipboard.script, "text", cid]
            stdout: StdioCollector { id: st }
            onExited: code => { if (code === 0 && d.open && d.open.id === cid) d.fullText = st.text; destroy(); }
        }
    }
}
