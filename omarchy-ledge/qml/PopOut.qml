import QtQuick
import Quickshell

// Small floating timer window. Float it with the windowrule in hyprland.conf.
FloatingWindow {
    id: w
    required property var timer
    required property var cfg
    title: "Ledge Timer"
    implicitWidth: 260
    implicitHeight: 170
    color: cfg.colors.bg

    TimerView {
        anchors.centerIn: parent
        timer: w.timer
        cfg: w.cfg
        compact: true
    }
}
