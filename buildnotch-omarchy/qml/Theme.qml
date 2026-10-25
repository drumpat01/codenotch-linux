pragma Singleton
import QtQuick

// Design tokens sampled from the buildnotch.app stylesheet.
QtObject {
    readonly property color page: "#08090b"
    readonly property color ink: "#0a0b0d"
    readonly property color glass: "#101215"
    readonly property color glass2: "#17191d"
    readonly property color text: "#e6e9ee"
    readonly property color dim: "#8a919c"
    readonly property color faint: "#565d66"
    readonly property color hair: Qt.rgba(0.902, 0.914, 0.933, 0.08)
    readonly property color hair2: Qt.rgba(0.902, 0.914, 0.933, 0.14)
    readonly property color cardBorder: Qt.rgba(0.902, 0.914, 0.933, 0.18)
    readonly property color cardBorderTop: Qt.rgba(1, 1, 1, 0.28)
    readonly property color accent: "#3ecf8e"
    readonly property color phos: "#33e69a"
    readonly property color phosDim: Qt.rgba(0.2, 0.902, 0.604, 0.14)
    readonly property color warn: "#ffb347"
    readonly property color bad: "#f7768e"

    readonly property int cardRadius: 20
    readonly property int shellRadius: 20
    readonly property int earRadius: 18          // concave corner where the open notch meets the screen edge
    readonly property int earRadiusCollapsed: 10
    readonly property real collapsedScale: 0.96  // buildnotch.app: the shell opens from scale 0.96 to 1
    readonly property int barHeight: 56
    readonly property int cardHeight: 332

    readonly property FontLoader dmSans: FontLoader { source: Qt.resolvedUrl("fonts/DMSans.ttf") }
    readonly property FontLoader mono: FontLoader { source: Qt.resolvedUrl("fonts/JetBrainsMono.ttf") }
    readonly property FontLoader pixel: FontLoader { source: Qt.resolvedUrl("fonts/PressStart2P.ttf") }
    readonly property FontLoader vt: FontLoader { source: Qt.resolvedUrl("fonts/VT323.ttf") }

    readonly property string sans: dmSans.name || "DM Sans"
    readonly property string monoFamily: mono.name || "JetBrains Mono"
    readonly property string pixelFamily: pixel.name || "Press Start 2P"
    readonly property string vtFamily: vt.name || "VT323"
}
