import QtQuick

// 56px top bar: logo chip, nav pills, Edit, system readouts, bell, gear, Close.
Item {
    id: bar
    required property var app
    property bool editing: false
    property bool bellOpen: false
    signal closeRequested()
    signal editToggled()
    signal pinToggled()
    height: Theme.barHeight

    readonly property var navItems: [
        { page: "home", glyph: "", icon: "assets/nav-home.png" },
        { page: "media", glyph: "", icon: "assets/nav-media.png" },
        { page: "files", glyph: "⤓", icon: "" },
        { page: "clipboard", glyph: "", icon: "assets/nav-clipboard.png" },
        { page: "playground", glyph: "", icon: "assets/nav-play.png" },
        { page: "settings", glyph: "⚟", icon: "" }
    ]
    readonly property var v: app.sys.v

    // Clicking empty bar space pins / unpins the notch.
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bar.pinToggled() }

    Image { id: logo; x: 16; anchors.verticalCenter: parent.verticalCenter; width: 34; height: 34; source: "assets/logo.png"; smooth: true; mipmap: true }

    Rectangle {
        id: nav; x: logo.x + logo.width + 14; anchors.verticalCenter: parent.verticalCenter
        height: 40; width: row.width + 8; radius: 20
        color: Qt.rgba(1, 1, 1, 0.05); border.color: Theme.hair; border.width: 1
        Row {
            id: row; x: 4; anchors.verticalCenter: parent.verticalCenter; spacing: 2
            Repeater {
                model: bar.navItems
                delegate: Rectangle {
                    required property var modelData
                    width: 42; height: 32; radius: 16
                    color: bar.app.page === modelData.page ? Qt.rgba(1, 1, 1, 0.14) : (m.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : "transparent")
                    Image { visible: modelData.icon !== ""; anchors.centerIn: parent; width: 16; height: 16; source: modelData.icon; smooth: true; opacity: 0.9 }
                    Text { visible: modelData.icon === ""; anchors.centerIn: parent; text: modelData.glyph; color: Theme.text; font.pixelSize: 15 }
                    MouseArea { id: m; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: bar.app.page = (bar.app.page === modelData.page && modelData.page !== "home") ? "home" : modelData.page }
                }
            }
        }
    }

    Row {
        anchors.right: parent.right; anchors.rightMargin: 18; anchors.verticalCenter: parent.verticalCenter; spacing: 18
        // Edit layout
        Row { spacing: 6; anchors.verticalCenter: parent.verticalCenter
            Text { text: "▦"; color: bar.editing ? Theme.phos : Theme.dim; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
            Text { text: bar.editing ? "Done" : "Edit"; color: bar.editing ? Theme.phos : Theme.text; font.pixelSize: 13; font.family: Theme.sans; anchors.verticalCenter: parent.verticalCenter }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bar.editToggled() } }
        Text { anchors.verticalCenter: parent.verticalCenter; text: "◎ " + bar.v.cpu + "%"; color: Theme.text; font.pixelSize: 13; font.family: Theme.sans }
        Text { anchors.verticalCenter: parent.verticalCenter; text: "▭ " + bar.v.ramUsed.toFixed(1) + "/" + Math.round(bar.v.ramTotal) + " GB"; color: Theme.text; font.pixelSize: 13; font.family: Theme.sans }
        Text { anchors.verticalCenter: parent.verticalCenter; text: "⇅ " + bar.v.net.toFixed(bar.v.net < 10 ? 1 : 0) + " MB/s"; color: Theme.text; font.pixelSize: 13; font.family: Theme.sans }
        Text { visible: bar.v.bat >= 0; anchors.verticalCenter: parent.verticalCenter; text: (bar.v.charging ? "⚡ " : "▮ ") + bar.v.bat + "%"; color: Theme.text; font.pixelSize: 13; font.family: Theme.sans }
        // Bell
        Item { width: 20; height: 24; anchors.verticalCenter: parent.verticalCenter
            Text { anchors.centerIn: parent; text: "🔔︎"; color: Theme.text; font.pixelSize: 15 }
            Rectangle { visible: bar.app.unread > 0; x: 12; y: 0; width: 8; height: 8; radius: 4; color: Theme.phos }
            MouseArea { anchors.fill: parent; anchors.margins: -5; cursorShape: Qt.PointingHandCursor
                onClicked: { bar.bellOpen = !bar.bellOpen; bar.app.unread = 0; } } }
        Text { anchors.verticalCenter: parent.verticalCenter; text: "⚙"; color: Theme.text; font.pixelSize: 17
            MouseArea { anchors.fill: parent; anchors.margins: -5; cursorShape: Qt.PointingHandCursor; onClicked: bar.app.page = bar.app.page === "settings" ? "home" : "settings" } }
        Text { anchors.verticalCenter: parent.verticalCenter; text: "Close"; color: "#fff"; font.pixelSize: 13; font.family: Theme.sans; font.weight: Font.DemiBold
            MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: bar.closeRequested() } }
    }
}
