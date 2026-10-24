import QtQuick
import QtQuick.Controls

TextField {
    property color fg: "#fff"
    property color surface: "#222"
    property color accent: "#7aa2f7"
    color: fg
    placeholderTextColor: Qt.darker(fg, 1.8)
    selectionColor: accent
    font.pixelSize: 13
    leftPadding: 10
    background: Rectangle { radius: 8; color: surface; border.width: parent.activeFocus ? 1 : 0; border.color: accent }
}
