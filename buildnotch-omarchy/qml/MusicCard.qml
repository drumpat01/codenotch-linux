import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

// Now playing through MPRIS: artwork, track, source badge, transport controls, seekable progress.
Card {
    id: root
    required property var app
    property bool big: false
    width: big ? 520 : 340

    readonly property var player: {
        const list = Mpris.players.values;
        for (let i = 0; i < list.length; i++) if (list[i].isPlaying) return list[i];
        return list.length > 0 ? list[0] : null;
    }
    readonly property real frac: player && player.lengthSupported && player.length > 0 ? Math.min(1, player.position / player.length) : 0

    Timer {
        interval: 1000; repeat: true; running: root.player !== null && root.player.isPlaying && root.visible
        onTriggered: root.player.positionChanged()
    }

    Column {
        anchors.fill: parent
        spacing: 12
        visible: root.player !== null

        Item {
            width: parent.width; height: parent.height - glass.height - 12
            Rectangle {
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height); height: width
                radius: 16; color: Theme.glass2; clip: true
                Image {
                    anchors.fill: parent
                    source: root.player ? root.player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop; asynchronous: true
                }
            }
        }

        Rectangle {
            id: glass
            width: parent.width; height: 96; radius: 16
            color: Qt.rgba(1, 1, 1, 0.04); border.color: Theme.hair; border.width: 1
            Row {
                x: 12; y: 12; spacing: 10; width: parent.width - 24
                Rectangle {
                    width: 44; height: 44; radius: 8; color: Theme.glass2; clip: true
                    Image { anchors.fill: parent; source: root.player ? root.player.trackArtUrl : ""; fillMode: Image.PreserveAspectCrop; asynchronous: true }
                }
                Column {
                    width: parent.width - 44 - 10 - 108
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text { width: parent.width; elide: Text.ElideRight; color: "#fff"; font.pixelSize: 14; font.family: Theme.sans; font.weight: Font.DemiBold
                        text: root.player ? (root.player.trackTitle || "Unknown title") : "" }
                    Text { width: parent.width; elide: Text.ElideRight; color: Theme.dim; font.pixelSize: 12; font.family: Theme.sans
                        text: root.player ? (root.player.trackArtist || root.player.identity) : "" }
                }
                Row {
                    spacing: 6; anchors.verticalCenter: parent.verticalCenter
                    Repeater {
                        model: [{ g: "⏮", k: "prev" }, { g: "play", k: "play" }, { g: "⏭", k: "next" }]
                        delegate: Item {
                            required property var modelData
                            width: 32; height: 32
                            Text {
                                anchors.centerIn: parent; color: "#fff"; font.pixelSize: 16
                                text: modelData.k === "play" ? (root.player && root.player.isPlaying ? "⏸" : "▶") : modelData.g
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!root.player) return;
                                    if (modelData.k === "prev" && root.player.canGoPrevious) root.player.previous();
                                    else if (modelData.k === "next" && root.player.canGoNext) root.player.next();
                                    else if (modelData.k === "play" && root.player.canTogglePlaying) root.player.togglePlaying();
                                }
                            }
                        }
                    }
                }
            }
            Rectangle {
                id: bar
                x: 12; y: parent.height - 18; width: parent.width - 24; height: 4; radius: 2
                color: Qt.rgba(1, 1, 1, 0.12)
                Rectangle { width: parent.width * root.frac; height: parent.height; radius: 2; color: Theme.phos
                    Behavior on width { NumberAnimation { duration: 400 } } }
                MouseArea {
                    anchors.fill: parent; anchors.topMargin: -8; anchors.bottomMargin: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        if (root.player && root.player.canSeek && root.player.lengthSupported)
                            root.player.position = mouse.x / bar.width * root.player.length;
                    }
                }
            }
        }
    }

    Column {
        anchors.centerIn: parent; spacing: 8; visible: root.player === null
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "♫"; color: Theme.faint; font.pixelSize: 34 }
        Text { text: "Nothing playing"; color: Theme.dim; font.pixelSize: 13; font.family: Theme.sans }
    }
}
