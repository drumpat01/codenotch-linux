//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    AppState { id: appState }

    Variants {
        model: Quickshell.screens
        Notch {
            required property var modelData
            screen: modelData
            app: appState
        }
    }

    PopOut { app: appState }

    // Bound from hyprland.conf:  bind = SUPER, grave, global, buildnotch:toggle
    GlobalShortcut { appid: "buildnotch"; name: "toggle"; description: "Toggle the notch"; onPressed: appState.toggleRequested() }
    GlobalShortcut { appid: "buildnotch"; name: "clipboard"; description: "Open clipboard history"; onPressed: appState.pageRequested("clipboard") }
}
