import QtQuick
import QtQuick.Layouts

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
        { page: "files", glyph: "", icon: "assets/icons/download.svg" },
        { page: "clipboard", glyph: "", icon: "assets/nav-clipboard.png" },
        { page: "playground", glyph: "", icon: "assets/nav-play.png" },
        { page: "settings", glyph: "", icon: "assets/icons/settings.svg" }
    ]
    readonly property var v: app.sys.v

    // The right-hand group is a RowLayout: children of a Row/Column positioner must not use vertical anchors
    // (Qt logs "scene: QML Row ... Cannot specify top, bottom, verticalCenter, fill or centerIn anchors").
    component Readout: RowLayout {
        property string icon
        property string text
        spacing: 5; Layout.alignment: Qt.AlignVCenter
        Icon { Layout.alignment: Qt.AlignVCenter; name: parent.icon; size: 14; color: Theme.dim }
        Text { Layout.alignment: Qt.AlignVCenter; text: parent.text; color: Theme.text; font.pixelSize: 13; font.family: Theme.sans }
    }

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
                    Image { visible: modelData.icon !== "" && modelData.icon.indexOf("/icons/") < 0; anchors.centerIn: parent; width: 16; height: 16; source: modelData.icon; smooth: true; opacity: 0.9 }
                    Icon { visible: modelData.icon.indexOf("/icons/") >= 0; anchors.centerIn: parent; size: 16; opacity: 0.9
                        name: modelData.icon.indexOf("/icons/") >= 0 ? modelData.icon.replace(/^.*\/icons\/|\.svg$/g, "") : "" }
                    MouseArea { id: m; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: bar.app.page = (bar.app.page === modelData.page && modelData.page !== "home") ? "home" : modelData.page }
                }
            }
        }
    }

    RowLayout {
        anchors.right: parent.right; anchors.rightMargin: 18; anchors.verticalCenter: parent.verticalCenter; spacing: 18
        // Edit layout
        Item { Layout.preferredWidth: editRow.implicitWidth; Layout.preferredHeight: editRow.implicitHeight; Layout.alignment: Qt.AlignVCenter
            RowLayout { id: editRow; spacing: 6
                Icon { name: "layout-grid"; size: 14; color: bar.editing ? Theme.phos : Theme.dim; Layout.alignment: Qt.AlignVCenter }
                Text { text: bar.editing ? "Done" : "Edit"; color: bar.editing ? Theme.phos : Theme.text; font.pixelSize: 13; font.family: Theme.sans; Layout.alignment: Qt.AlignVCenter } }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bar.editToggled() } }
        Readout { icon: "cpu"; text: bar.v.cpu + "%" }
        Readout { icon: "memory"; text: bar.v.ramUsed.toFixed(1) + "/" + Math.round(bar.v.ramTotal) + " GB" }
        Readout { icon: "net"; text: bar.v.net.toFixed(bar.v.net < 10 ? 1 : 0) + " MB/s" }
        Readout { visible: bar.v.bat >= 0; icon: bar.v.charging ? "zap" : "battery"; text: bar.v.bat + "%" }
        // Bell
        Item { Layout.preferredWidth: 20; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignVCenter
            Icon { anchors.centerIn: parent; name: "bell"; size: 16; color: Theme.text }
            Rectangle { visible: bar.app.unread > 0; x: 12; y: 0; width: 8; height: 8; radius: 4; color: Theme.phos }
            MouseArea { anchors.fill: parent; anchors.margins: -5; cursorShape: Qt.PointingHandCursor
                onClicked: { bar.bellOpen = !bar.bellOpen; bar.app.unread = 0; } } }
        Icon { Layout.alignment: Qt.AlignVCenter; name: "settings"; size: 17; color: Theme.text
            MouseArea { anchors.fill: parent; anchors.margins: -5; cursorShape: Qt.PointingHandCursor; onClicked: bar.app.page = bar.app.page === "settings" ? "home" : "settings" } }
        Text { Layout.alignment: Qt.AlignVCenter; text: "Close"; color: "#fff"; font.pixelSize: 13; font.family: Theme.sans; font.weight: Font.DemiBold
            MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: bar.closeRequested() } }
    }
}
