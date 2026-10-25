import QtQuick
import QtQuick.Effects

// A bundled SVG icon (assets/icons/<name>.svg), recoloured to `color`.
Item {
    id: ic
    property string name: ""
    property color color: "#ffffff"
    property real size: 16
    width: size; height: size
    Image {
        id: img; anchors.fill: parent; visible: false
        source: ic.name ? "assets/icons/" + ic.name + ".svg" : ""
        sourceSize: Qt.size(ic.size * 2, ic.size * 2); smooth: true; mipmap: true
    }
    MultiEffect { anchors.fill: parent; source: img; colorization: 1; colorizationColor: ic.color }
}
