# Ledge — a hover notch for Omarchy (Hyprland)

A thin bar centered at the top of the screen (a wlr-layer-shell overlay, so it coexists with Waybar).
It expands when the pointer enters, collapses when it leaves, and **clicking pins it open**.

Panels: **Music** (MPRIS), **Focus timer** (custom length, notification, pop-out window),
**Tasks & note** (per-project tasks + quick note, saved as JSON), **Shortcuts** (.desktop apps, project
folders in terminal/editor), **GitHub** (contribution graph via `gh`).

Built with [Quickshell](https://quickshell.org) (QML). Independent of the macOS/Windows Codenotch code in this repo.

## Install (Omarchy / Arch)

```sh
sudo pacman -S --needed quickshell libnotify github-cli
gh auth login            # once, for the GitHub panel
./install.sh             # installs to ~/.local/share/ledge-app and ~/.local/bin/ledge
```
Then add `hyprland.conf` from this folder to `~/.config/hypr/hyprland.conf` (or Omarchy's `autostart.conf`),
and run `ledge` (or log out/in). Alternatively build the package: `makepkg -si` (PKGBUILD).
Uninstall: `./install.sh --uninstall`. Hyprland windowrule syntax changed in recent releases; adjust
the pop-out rule if yours differs (it only needs to float the window titled "Ledge Timer").

## Config

`~/.config/ledge/config.json` (created from `config.example.json`, reloaded on save). Keys: `monitor`,
`expandedWidth/Height`, `timerMinutes`, `terminal`, `editor`, `projects`, `githubRefreshMinutes`, `colors`.
Tasks/note are stored in `~/.local/share/ledge/data.json`. No tokens are stored; GitHub uses your `gh` login.

## Development

`./scripts/check.sh` runs the logic tests (`node tests/lib.test.js`), validates the example config and lints
QML if `qmllint` is installed. Run in place with `bin/ledge` inside a Hyprland session.

## Screenshots

_To be added after the first run on a real Omarchy machine (see PR)._
