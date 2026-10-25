import QtQuick

// A dashboard card: separate, bordered, 20px radius, vertical gradient (site `.di-card`).
Rectangle {
    id: card
    property string title: ""
    property color fill1: Qt.rgba(0.031, 0.039, 0.047, 0.97)
    property color fill2: Qt.rgba(0.067, 0.078, 0.09, 0.96)
    default property alias children2: holder.data
    height: Theme.cardHeight
    radius: Theme.cardRadius
    border.width: 1
    border.color: Theme.cardBorder
    gradient: Gradient {
        GradientStop { position: 0; color: card.fill1 }
        GradientStop { position: 1; color: card.fill2 }
    }
    // Brighter top edge, like `border-top-color`.
    Rectangle { x: card.radius; y: 0; width: parent.width - card.radius * 2; height: 1; color: Theme.cardBorderTop; opacity: 0.6 }
    Item { id: holder; anchors.fill: parent; anchors.margins: 18 }
}
