import QtQuick
import "Lib.js" as Lib

// AI usage: one ring per provider, tap a ring for its usage windows and resets. Unavailable data is labelled, never faked.
Card {
    id: root
    required property var app
    width: 300
    property int sel: 0
    readonly property var readings: app.usage.readings
    readonly property var cur: readings.length > 0 ? readings[Math.min(sel, readings.length - 1)] : null

    function resetText(iso) {
        if (!iso) return "";
        var d = new Date(iso);
        return isNaN(d.getTime()) ? "" : "Resets " + d.toLocaleString(Qt.locale(), "MMM d, h:mm AP");
    }

    Text { id: ttl; text: "AI usage"; color: "#fff"; font.pixelSize: 13; font.family: Theme.sans; font.weight: Font.DemiBold }
    Row {
        id: rings; y: 30; spacing: 12
        Repeater {
            model: root.readings
            delegate: Item {
                required property var modelData
                required property int index
                width: 52; height: 66
                Ring {
                    width: 46; height: 46; anchors.horizontalCenter: parent.horizontalCenter
                    stroke: 4; fill: index === root.sel ? Theme.phos : "#fff"
                    track: Qt.rgba(1, 1, 1, 0.12)
                    progress: modelData.ok && modelData.windows.length ? (100 - modelData.windows[0].used) / 100 : 0
                }
                Text { anchors.horizontalCenter: parent.horizontalCenter; y: 13; text: modelData.name.charAt(0); color: "#fff"; font.pixelSize: 14; font.family: Theme.sans; font.weight: Font.Bold }
                Text { anchors.horizontalCenter: parent.horizontalCenter; y: 50; text: modelData.name; color: Theme.dim; font.pixelSize: 9; font.family: Theme.sans }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.sel = index }
            }
        }
    }
    Column {
        y: 108; width: parent.width; spacing: 10
        visible: root.cur !== null
        Text { text: root.cur ? root.cur.name + " usage" + (root.cur.plan ? " · " + root.cur.plan : "") : ""; color: "#fff"; font.pixelSize: 13; font.family: Theme.sans; font.weight: Font.DemiBold }
        Text { visible: root.cur && !root.cur.ok; width: parent.width; wrapMode: Text.Wrap; color: Theme.dim; font.pixelSize: 11; font.family: Theme.sans
            text: root.cur ? root.cur.error + ". Set a usage command for this provider in Settings, AI." : "" }
        Repeater {
            model: root.cur && root.cur.ok ? root.cur.windows : []
            delegate: Column {
                required property var modelData
                width: parent.width; spacing: 3
                Text { text: modelData.label; color: Theme.dim; font.pixelSize: 11; font.family: Theme.sans }
                Text { visible: text !== ""; text: root.resetText(modelData.resetsAt); color: Theme.faint; font.pixelSize: 10; font.family: Theme.sans }
                Rectangle { width: parent.width; height: 5; radius: 2.5; color: Qt.rgba(1, 1, 1, 0.1)
                    Rectangle { width: parent.width * (100 - modelData.used) / 100; height: parent.height; radius: 2.5
                        color: modelData.used > 85 ? Theme.bad : (modelData.used > 60 ? Theme.warn : Theme.phos) } }
                Text { text: Math.round(modelData.used) + "% used · " + Math.round(100 - modelData.used) + "% left"; color: Theme.dim; font.pixelSize: 10; font.family: Theme.sans }
            }
        }
        Text { visible: root.cur && root.cur.ok; text: root.cur ? "Last reading " + Lib.relTime(root.cur.at) : ""; color: Theme.faint; font.pixelSize: 9; font.family: Theme.monoFamily }
    }
    Text { visible: root.cur === null; anchors.centerIn: parent; text: "No providers enabled"; color: Theme.faint; font.pixelSize: 12; font.family: Theme.sans }
}
