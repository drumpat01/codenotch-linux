# BuildNotch for Omarchy: feature list and port status

Source of truth: https://www.buildnotch.app/ (home page, changelog 1.1.0 / 1.2.0, the "Windows notch apps"
guide and the AWNA / Notchify / Winotch / Smart Notch / Widgets / Clipboard comparison pages), studied on
2026-10-24. Look: black surfaces, white type, vivid green accent (`#3ecf8e` / phosphor `#33e69a`), DM Sans +
JetBrains Mono, 20px bordered cards, a 56px top bar, a bottom hotkey bar, and a notch that drops from the
top edge with a spring-like open. Design tokens were taken from the site CSS (`Theme.qml`).

Status key: **Done** = ported 1:1, **Adapted** = same feature through a Linux mechanism, **Partial** = works
with a stated limit, **N/A** = Windows-only, no Linux equivalent.

Nothing here has been run on a real Omarchy machine from the build sandbox (no Quickshell or Hyprland
there). `scripts/check.sh` runs the logic tests; the on-device test steps are in the PR.

## Shell and behaviour

| # | Feature (as on buildnotch.app) | Linux implementation | Status |
|---|---|---|---|
| 1 | Notch at the top-centre of the screen, black, flush with the top edge, inverse-rounded bottom corners (`border-radius: 0 0 20px 20px`) | Quickshell `PanelWindow` on the wlr-layer-shell overlay layer, input mask limited to the notch body and its two concave corner ears; sits below any bar that reserves screen space (`topOffset` overrides) | Done |
| 2 | Collapsed notch with a glance: clock (`10:42`), live focus countdown, now-playing bars | `Notch.qml` collapsed state | Done |
| 3 | "Open on hover": bar opens when the pointer enters it, closes when it leaves | HoverHandler with open/close delays; toggle in Settings | Done |
| 4 | "Click the bar to pin it open" | Click the bar to pin and unpin; Esc closes | Done |
| 5 | Open/close animation (shell scale 0.96 to 1, width/height morph, content fade) | `NumberAnimation` with OutBack/OutCubic easing; collapsed scale 0.96 (`Theme.collapsedScale`) | Done |
| 6 | Global toggle hotkey (`Win + \``) | Hyprland `global` shortcut `buildnotch:toggle`, bound to `SUPER + ALT + N` because `SUPER + \`` is Omarchy's scratchpad on 4.5+ (`toggleHint` sets the label) | Adapted |
| 7 | `Esc` closes, `Mouse wheel` browses cards, hotkey hint bar under the cards | Same hint bar, wheel scrolls the card row | Done |
| 8 | `ALT + 1 – 6` launches the first six AI apps | Qt `Shortcut`; layer-shell only gives keyboard focus after a click, so click the notch once first | Adapted |
| 9 | Short notch (1.2.0): narrower collapsed notch, Settings, General | `shortNotch` setting | Done |
| 10 | Fullscreen app rules (1.2.0): only Chrome hides the notch by default, per-app rules in Settings | Re-reads `hyprctl activewindow -j` only on Hyprland socket events (fullscreen, focus, workspace, close); default hides for Chrome/Chromium; per-class list in Settings | Adapted |
| 11 | Multi-monitor / configurable screen placement | `monitor` config key, one notch per screen otherwise | Done |
| 12 | Light/dark theme icons on the site (sun/moon) | The app itself is dark-only on the site; icons bundled, theme follows the dark palette | Partial |

## Top bar

| # | Feature | Implementation | Status |
|---|---|---|---|
| 13 | App icon chip, nav pills: Home, Media, File tray, Clipboard, Playground, Settings | `TopBar.qml`, pills switch the drawer/page | Done |
| 14 | "Edit layout" button | Edit mode toggle (see 33) | Done |
| 15 | System readouts: CPU %, RAM used / total GB, NET MB/s, battery with charge bolt | `SysStats.qml` reads `/proc/stat`, `/proc/meminfo`, `/proc/net/dev`, `/sys/class/power_supply` | Done |
| 16 | Bell button | Recent notch events (timer finished, copied) with a badge; clear | Adapted |
| 17 | Settings gear, "Close" button | Same | Done |

## Cards (the Home dashboard)

| # | Feature | Implementation | Status |
|---|---|---|---|
| 18 | **Music**: artwork, title, artist, source badge, previous/play/next, progress bar | MPRIS via `Quickshell.Services.Mpris` (seekable progress); transport icons from the site, source badge (Spotify, Firefox, ...) on the artwork | Done |
| 19 | **Focus timer**: ring, `25:00`, READY state, Focus / Short / Long modes, session counter and dots, start/reset, adjustable length ("update the timer, custom timers") | `PomodoroCard.qml` + `PomodoroModel.qml`; lengths editable in the card | Done |
| 20 | Seven timer styles: Clean, Pixel dusk, Dots, Retro clock, Focus terminal, Zen, Cyber HUD (incl. the FUEL / TACH / MPH gauge look) | `PomodoroView.qml` (all seven styles), fonts Press Start 2P and VT323 bundled (OFL) | Done |
| 21 | Drag the timer out onto the desktop | Pop-out button and drag-out gesture open a floating window (`BuildNotch Timer`) with a Hyprland float rule | Adapted |
| 22 | Desktop notification when the timer ends | `notify-send` | Adapted |
| 23 | **AI apps**: installed supported apps detected and launchable, add your own shortcuts, `ALT+n` | `.desktop` entries matched against a known list (Claude, ChatGPT, Codex, Cursor, Antigravity, T3 Code, Windsurf, Zed, Ollama ...) plus user shortcuts | Adapted |
| 24 | **AI usage**: provider rings, pick a provider, usage windows ("5-hour limit", "Weekly limit"), reset times, plan, "unavailable" instead of fake 0%, last-reading time, choose which providers appear | UI is complete; data comes from per-provider commands in config (`usage.providers[].command` printing JSON). No provider ships with a built-in network call or credential read, so every provider shows "unavailable" until you set one | Partial |
| 25 | **GitHub**: avatar, contribution heat grid, "N contributions · last 18 weeks", Refresh | `gh api graphql` with the user's existing `gh` login; avatar via `gh api user` | Done |
| 26 | **Projects and tasks**: projects with tasks, dates, completion, "Project: Portfolio", next task close | `ProjectsCard.qml`, JSON store, project folder/site shortcuts | Done |
| 27 | **Quote**: short founder/philosophy lines, Next button | 40 bundled lines, shuffle | Done |
| 28 | **Favorite apps**: launch the apps you live in; add your own | `.desktop` picker plus free-form command | Done |
| 29 | **Code playground**: language picker (JavaScript, TypeScript, Rust, Python, Plain text), line numbers, "Saved locally as you type", Copy, Clear | `PlaygroundDrawer.qml` | Done |
| 30 | **Personal note**: word count, Today, Saved state | `NoteCard.qml` | Done |
| 31 | **Clipboard history** (`WIN + V`, here `SUPER + ALT + V` because Omarchy uses SUPER+V for Universal paste): filters All / Text / Code / Images / Links, grid, copy, remove, focused preview, "12 sec ago" | `cliphist` + `wl-clipboard`; the clipboard watcher is the user's existing `wl-paste --watch cliphist store` (Omarchy ships it) | Adapted |
| 32 | **File tray**: drop files in, thumbnails, export or drag out, removing a tray copy never deletes the original | `DropArea` copies into `~/.local/share/buildnotch/tray`; drag-out and "Open folder" | Done |
| 33 | **Edit layout**: widgets jiggle, lift while dragged, settle on release, reduced-motion respected | Card reorder by drag, jiggle animation, `reduceMotion` setting | Done |
| 34 | **JSON formatting** (Developer tools, Format): pretty-print / minify, copy, error shows where parsing failed | `PlaygroundDrawer.qml`, `Lib.js` (line/column from the parser message) | Done |

## Settings

| # | Feature | Implementation | Status |
|---|---|---|---|
| 35 | Pomodoro style picker ("changes every timer card") | Settings, Appearance | Done |
| 36 | Open on hover toggle | Settings, General | Done |
| 37 | Show/hide dashboard cards; hidden cards keep their position | `widgets` list with `visible` flags | Done |
| 38 | Custom notch wallpaper, dimmed so controls stay readable | Image path in Settings, Appearance, drawn under a dim layer | Done |
| 39 | Short notch, fullscreen app rules | See 9 and 10 | Done |
| 40 | Choose which AI providers appear | See 24 | Done |

## Windows-only or not applicable

| # | Feature | Why | Status |
|---|---|---|---|
| 41 | Installer, Polar licence/purchase flow, SmartScreen note | Linux install is `install.sh` / PKGBUILD, no licence check is built | N/A |
| 42 | Windows media session API | Replaced by MPRIS (row 18) | Adapted |
| 43 | Windows 10/11 notch placement | Replaced by layer-shell (row 1) | Adapted |

## Not ported on purpose

Marketing-site items (testimonials, pricing, cookie banner, comparison pages) and the 3D product renders.
The app logo, the small navigation icons, the tomato and the pixel cat are reused from buildnotch.app at
the owner's request; they should be cleared with the BuildNotch author before any public release.
