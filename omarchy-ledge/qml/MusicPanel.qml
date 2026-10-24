import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

Item {
    id: root
    required property var cfg
    readonly property var c: cfg.colors

    readonly property var player: {
        const list = Mpris.players.values;
        for (let i = 0; i < list.length; i++) if (list[i].isPlaying) return list[i];
        return list.length > 0 ? list[0] : null;
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 14
        visible: root.player !== null
        RowLayout {
            spacing: 14
            Layout.alignment: Qt.AlignHCenter
            Rectangle {
                Layout.preferredWidth: 96; Layout.preferredHeight: 96
                radius: 10; color: c.surface; clip: true
                Image {
                    anchors.fill: parent
                    source: root.player ? root.player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }
            ColumnLayout {
                Layout.preferredWidth: 280
                spacing: 4
                Text { Layout.fillWidth: true; elide: Text.ElideRight; color: c.fg; font.pixelSize: 18; font.bold: true; text: root.player ? (root.player.trackTitle || "Unknown title") : "" }
                Text { Layout.fillWidth: true; elide: Text.ElideRight; color: c.dim; font.pixelSize: 14; text: root.player ? (root.player.trackArtist || "") : "" }
                Text { Layout.fillWidth: true; elide: Text.ElideRight; color: c.dim; font.pixelSize: 12; text: root.player ? root.player.identity : "" }
            }
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            Btn { label: "⏮"; fg: c.fg; surface: c.surface; enabled: root.player && root.player.canGoPrevious; onClicked: root.player.previous() }
            Btn {
                label: root.player && root.player.isPlaying ? "⏸  Pause" : "▶  Play"
                primary: true; accent: c.accent; fg: c.fg
                enabled: root.player && root.player.canTogglePlaying
                onClicked: root.player.togglePlaying()
            }
            Btn { label: "⏭"; fg: c.fg; surface: c.surface; enabled: root.player && root.player.canGoNext; onClicked: root.player.next() }
        }
    }
    Text {
        anchors.centerIn: parent
        visible: root.player === null
        color: c.dim; font.pixelSize: 15
        text: "Nothing playing — start a media player (MPRIS)."
    }
}
