# BuildNotch for Omarchy (Hyprland)

A Linux port of [BuildNotch](https://www.buildnotch.app/): a notch at the top of the screen that opens on hover
and holds your music, focus timer, AI apps and usage, GitHub activity, projects and tasks, quote, favorite apps,
note, code playground, JSON formatter, clipboard history and file tray. See [FEATURES.md](FEATURES.md) for every
feature and its port status.

Built with [Quickshell](https://quickshell.org) (QML) as a wlr-layer-shell overlay, so it sits above Waybar without
reserving space. Quickshell gives MPRIS, the desktop-entry database, Hyprland global shortcuts and animated,
fully custom drawing in one process, which is what a pixel-faithful notch needs. It is independent of the
macOS/Windows Codenotch code in this repo and of `omarchy-ledge/`.

## Install (Omarchy / Arch)

```sh
sudo pacman -S --needed quickshell libnotify github-cli cliphist wl-clipboard
gh auth login            # once, for the GitHub card
./install.sh             # to ~/.local/share/buildnotch-app and ~/.local/bin/buildnotch
```

Add the lines from [`hyprland.conf`](hyprland.conf) to `~/.config/hypr/hyprland.conf` (or Omarchy's
`autostart.conf` / `bindings.conf`), then run `buildnotch` or log out and in. A package is available through
`makepkg -si` (PKGBUILD). Uninstall with `./install.sh --uninstall`.

Clipboard history needs the watcher `wl-paste --watch cliphist store`, which Omarchy already starts.

## Use

| Action | How |
|---|---|
| Open | Move the pointer to the top-centre notch (Settings, General turns hover off) |
| Pin open | Click the notch or an empty part of the bar; click again to unpin |
| Toggle | `SUPER + \`` |
| Close | `Esc` or the Close button |
| Browse cards | Mouse wheel over the cards |
| Launch AI apps | `ALT + 1` to `6` (click the notch once so it has keyboard focus) |
| Clipboard history | Bar icon or `SUPER + ALT + V` |
| Rearrange cards | Edit, then drag a card; Done to finish |

## Config

`~/.config/buildnotch/config.json` is created on first run and rewritten by the Settings panel; edit either.
Tasks, notes and the playground are in `~/.local/share/buildnotch/data.json`, the file tray in
`~/.local/share/buildnotch/tray/`. No tokens are stored anywhere: GitHub uses your `gh` login.

### AI usage

No provider ships with a built-in network call or credential read. Each provider in Settings, AI has an optional
command that prints JSON; without one the provider shows as unavailable, never as 0% used:

```json
{ "plan": "Plus", "windows": [ { "label": "5-hour limit", "usedPercent": 12, "resetsAt": "2026-10-24T22:00:00Z" } ] }
```

## Development

`./scripts/check.sh` runs the logic tests (`node tests/lib.test.js`), validates the example config, lints QML if
`qmllint` is installed and syntax-checks the shell scripts. Run in place with `bin/buildnotch` inside Hyprland.

## Screenshots

These are offscreen renders of the real QML components with sample data (the sandbox that built this has no
Wayland session). Real on-device screenshots are still to be added.

![Seven timer styles](docs/render-timer-styles.png)
![GitHub, projects, AI usage, quote and note cards](docs/render-cards.png)
