import QtQuick
import QtQuick.Layouts
import "Lib.js" as Lib

// Shared by the in-notch panel and the floating pop-out window.
ColumnLayout {
    id: root
    required property var timer
    required property var cfg
    property bool compact: false
    readonly property var c: cfg.colors
    spacing: 12

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: Lib.fmt(root.timer.remaining)
        color: root.timer.running ? c.accent : c.fg
        font.pixelSize: root.compact ? 44 : 64
        font.weight: Font.DemiBold
        font.family: "monospace"
    }
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 10
        Btn {
            label: root.timer.running ? "Pause" : "Start"
            primary: true; accent: c.accent; fg: c.fg
            onClicked: root.timer.running ? root.timer.pause() : root.timer.start()
        }
        Btn { label: "Reset"; fg: c.fg; surface: c.surface; onClicked: root.timer.reset() }
    }
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        visible: !root.compact
        spacing: 8
        Text { text: "Minutes"; color: c.dim; font.pixelSize: 13 }
        Field {
            id: mins
            Layout.preferredWidth: 70
            fg: c.fg; surface: c.surface; accent: c.accent
            text: String(root.timer.lengthSec / 60)
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: root.timer.setMinutes(parseFloat(text))
        }
        Btn { label: "Set"; fg: c.fg; surface: c.surface; onClicked: root.timer.setMinutes(parseFloat(mins.text)) }
        Btn { label: "Pop out"; fg: c.fg; surface: c.surface; onClicked: root.popOut() }
    }
    signal popOut()
}
