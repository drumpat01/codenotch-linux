#!/bin/sh
# Install BuildNotch for the current user (no root needed).
#   ./install.sh            install
#   ./install.sh --hypr     also add the binds, autostart and window rules to your Hyprland config
#   ./install.sh --uninstall
set -eu
src="$(cd "$(dirname "$0")" && pwd)"
share="${XDG_DATA_HOME:-$HOME/.local/share}/buildnotch-app"
bin="$HOME/.local/bin"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}/buildnotch"
hypr="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"

# 'quoted' for sh, safe for any path.
sq() { printf "'%s'" "$(printf %s "$1" | sed "s/'/'\\\\''/g")"; }

# Add a marked block to a file once.
append_block() { # file comment-prefix body
    if [ -f "$1" ] && grep -q "buildnotch (added by install.sh)" "$1"; then
        echo "  $1: already has the BuildNotch block, left alone"
        return
    fi
    mkdir -p "$(dirname "$1")"
    printf '\n%s buildnotch (added by install.sh)\n%s\n' "$2" "$3" >> "$1"
    echo "  $1: added"
}

configure_hypr() {
    if [ -f "$hypr/bindings.lua" ]; then
        echo "Omarchy 4.x (Lua config) detected:"
        append_block "$hypr/autostart.lua" "--" 'o.launch_on_start("buildnotch")'
        append_block "$hypr/bindings.lua" "--" 'o.bind("SUPER + ALT + N", "BuildNotch: toggle", hl.dsp.global("buildnotch:toggle"))
o.bind("SUPER + ALT + V", "BuildNotch: clipboard history", hl.dsp.global("buildnotch:clipboard"))
o.window({ title = "^(BuildNotch Timer)$" }, { float = true, pin = true, move = { "(monitor_w-window_w-40)", "80" } })
hl.layer_rule({ match = { namespace = "^buildnotch$" }, blur = true, ignore_alpha = 0.3 })'
    elif [ -f "$hypr/bindings.conf" ] || [ -f "$hypr/hyprland.conf" ]; then
        echo "Omarchy 3.x / plain Hyprland (.conf) detected:"
        append_block "$hypr/autostart.conf" "#" 'exec-once = buildnotch'
        append_block "$hypr/bindings.conf" "#" 'bind = SUPER ALT, N, global, buildnotch:toggle
bind = SUPER ALT, V, global, buildnotch:clipboard
windowrule = float on, match:title ^(BuildNotch Timer)$
windowrule = pin on, match:title ^(BuildNotch Timer)$
windowrule = move (monitor_w-320) 80, match:title ^(BuildNotch Timer)$
layerrule = blur on, match:namespace buildnotch'
    else
        echo "No Hyprland config found in $hypr; copy the lines from hyprland.conf (3.x) or hyprland.lua (4.x) by hand." >&2
        return 1
    fi
}

if [ "${1:-}" = "--uninstall" ]; then
    rm -rf "$share" "$bin/buildnotch"
    echo "Removed. Config in $cfg and data in ${XDG_DATA_HOME:-$HOME/.local/share}/buildnotch were kept."
    echo "Remove the 'buildnotch (added by install.sh)' blocks from your Hyprland config if you added them."
    exit 0
fi

command -v quickshell >/dev/null 2>&1 || {
    echo "quickshell not found. Install deps: sudo pacman -S --needed quickshell qt6-svg libnotify github-cli cliphist wl-clipboard xdg-utils" >&2
    exit 1
}
for c in cliphist wl-copy gh notify-send xdg-open hyprctl; do
    command -v "$c" >/dev/null 2>&1 || echo "note: '$c' not found; the feature that needs it will be unavailable (see README)." >&2
done
mkdir -p "$share" "$bin" "$cfg"
rm -rf "$share/qml"
cp -r "$src/qml" "$share/qml"
chmod +x "$share"/qml/scripts/*.sh
printf '#!/bin/sh\nBUILDNOTCH_DIR=%s exec %s "$@"\n' "$(sq "$share")" "$(sq "$share/buildnotch-run")" > "$bin/buildnotch"
cp "$src/bin/buildnotch" "$share/buildnotch-run"
chmod +x "$bin/buildnotch" "$share/buildnotch-run"
[ -f "$cfg/config.json" ] || cp "$src/config.example.json" "$cfg/config.json"
echo "Installed to $share."
if [ "${1:-}" = "--hypr" ]; then
    configure_hypr || exit 1
    echo "Log out and in (or run 'buildnotch') to start it."
else
    echo "Run 'buildnotch', and add the binds: './install.sh --hypr' does it, or copy hyprland.conf (Omarchy 3.x) / hyprland.lua (Omarchy 4.x)."
fi
