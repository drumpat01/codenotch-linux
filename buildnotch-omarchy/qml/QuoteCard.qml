import QtQuick
import "Lib.js" as Lib

// A line for the hard hours.
Card {
    id: root
    required property var app
    width: 280
    readonly property int qi: app.db.quote % Lib.QUOTES.length

    Row { spacing: 8; height: 24
        Image { source: "assets/quotes.png"; width: 20; height: 20; smooth: true; anchors.verticalCenter: parent.verticalCenter }
        Text { anchors.verticalCenter: parent.verticalCenter; text: "Quote"; color: "#fff"; font.pixelSize: 13; font.family: Theme.sans; font.weight: Font.DemiBold } }
    Text {
        anchors.centerIn: parent; width: parent.width - 8; wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter
        text: "“" + Lib.QUOTES[root.qi] + "”"; color: Theme.text; font.pixelSize: 17; font.family: Theme.sans; lineHeight: 1.25
    }
    Btn { anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; label: "Next"
        onClicked: root.app.setData("quote", (root.qi + 1 + Math.floor(Math.random() * (Lib.QUOTES.length - 1))) % Lib.QUOTES.length) }
}
