import QtQuick

// GitHub: avatar, heat grid of the last 18 weeks, contribution total, Refresh. Uses the existing `gh` login.
Card {
    id: root
    required property var app
    width: 300
    fill1: Qt.rgba(0.024, 0.067, 0.043, 0.97)
    fill2: Qt.rgba(0.04, 0.09, 0.063, 0.96)
    readonly property var g: app.gh
    readonly property var levels: ["#17241b", "#1c4a34", "#1f7a50", "#2eae76", "#48d99a"]

    Row {
        anchors.horizontalCenter: parent.horizontalCenter; spacing: 8; height: 26
        Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 22; height: 22; radius: 11; color: "#fff"
            Text { anchors.centerIn: parent; text: "⑂"; color: "#0a0b0d"; font.pixelSize: 14; font.weight: Font.Bold } }
        Text { anchors.verticalCenter: parent.verticalCenter; text: "GitHub"; color: "#fff"; font.pixelSize: 16; font.family: Theme.sans; font.weight: Font.DemiBold }
    }
    Rectangle {
        id: av; y: 38; anchors.horizontalCenter: parent.horizontalCenter; width: 52; height: 52; radius: 26; color: Theme.glass2; clip: true
        Image { anchors.fill: parent; source: root.g.result ? root.g.result.avatar : ""; fillMode: Image.PreserveAspectCrop; asynchronous: true }
    }
    Row {
        id: grid; y: 104; anchors.horizontalCenter: parent.horizontalCenter; spacing: 3
        visible: root.g.result !== null
        Repeater {
            model: root.g.result ? root.g.result.weeks : []
            delegate: Column {
                required property var modelData
                spacing: 3
                Repeater {
                    model: modelData
                    delegate: Rectangle {
                        required property var modelData
                        width: 10; height: 10; radius: 3
                        color: root.levels[modelData.level]
                        HoverHandler { id: hh }
                        ToolTipLabel { shown: hh.hovered; text: modelData.count + " on " + modelData.date }
                    }
                }
            }
        }
    }
    Text {
        y: 104; width: parent.width; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap
        visible: root.g.result === null; color: root.g.error ? Theme.bad : Theme.dim; font.pixelSize: 11; font.family: Theme.sans
        text: root.g.error ? root.g.error : "Loading GitHub activity…"
    }
    Text {
        y: 104 + 7 * 13 + 14; width: parent.width; horizontalAlignment: Text.AlignHCenter
        visible: root.g.result !== null; color: Theme.dim; font.pixelSize: 12; font.family: Theme.sans
        text: root.g.result ? root.g.result.total + " contributions · last 18 weeks" : ""
    }
    Text {
        anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
        text: root.g.loading ? "Refreshing…" : "Refresh"; color: Theme.dim; font.pixelSize: 13; font.family: Theme.sans; font.weight: Font.DemiBold
        MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: root.g.refresh() }
    }
}
