import QtQuick

// Full-width panel that replaces the card row (site `.clipboard-drawer`, `.playground-drawer`, `.settings-drawer`).
Item {
    id: d
    property string title: ""
    property string shortcut: ""
    property alias headerExtra: extra.data
    default property alias body: content.data
    Row {
        id: head; x: 16; y: 4; width: parent.width - 32; height: 30; spacing: 12
        Text { anchors.verticalCenter: parent.verticalCenter; text: d.title; color: "#fff"; font.pixelSize: 16; font.family: Theme.sans; font.weight: Font.DemiBold }
        Text { anchors.verticalCenter: parent.verticalCenter; text: d.shortcut; color: Theme.faint; font.pixelSize: 10; font.family: Theme.monoFamily }
        Item { id: extra; height: 1; width: parent.width - x - 40 }
    }
    Item { id: content; x: 16; y: head.y + head.height + 8; width: parent.width - 32; height: parent.height - y - 12 }
}
