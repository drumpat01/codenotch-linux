import QtQuick

// Single-line text input in the notch's style.
Rectangle {
    id: f
    property alias text: input.text
    property string placeholder: ""
    property int pixelSize: 12
    signal accepted()
    implicitHeight: 30
    radius: 8
    color: Qt.rgba(1, 1, 1, 0.05)
    border.color: input.activeFocus ? Theme.accent : Theme.hair2
    border.width: 1
    TextInput {
        id: input
        anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.text; font.pixelSize: f.pixelSize; font.family: Theme.sans
        selectByMouse: true; clip: true
        onAccepted: f.accepted()
        Text { visible: !input.text && !input.activeFocus; text: f.placeholder; color: Theme.faint; font: input.font; anchors.verticalCenter: parent.verticalCenter }
    }
    function forceFocus() { input.forceActiveFocus(); }
}
