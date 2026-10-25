#!/bin/sh
# Install BuildNotch for the current user (no root needed). Use --uninstall to remove.
set -eu
src="$(cd "$(dirname "$0")" && pwd)"
share="${XDG_DATA_HOME:-$HOME/.local/share}/buildnotch-app"
bin="$HOME/.local/bin"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}/buildnotch"

if [ "${1:-}" = "--uninstall" ]; then
    rm -rf "$share" "$bin/buildnotch"
    echo "Removed. Config in $cfg and data in ${XDG_DATA_HOME:-$HOME/.local/share}/buildnotch were kept."
    exit 0
fi

command -v quickshell >/dev/null 2>&1 || {
    echo "quickshell not found. Install deps: sudo pacman -S --needed quickshell libnotify github-cli cliphist wl-clipboard" >&2
    exit 1
}
for c in cliphist wl-copy gh notify-send; do
    command -v "$c" >/dev/null 2>&1 || echo "note: '$c' not found; the feature that needs it will be unavailable (see README)." >&2
done
mkdir -p "$share" "$bin" "$cfg"
rm -rf "$share/qml"
cp -r "$src/qml" "$share/qml"
chmod +x "$share"/qml/scripts/*.sh
printf '#!/bin/sh\nBUILDNOTCH_DIR="%s" exec "%s/buildnotch-run" "$@"\n' "$share" "$share" > "$bin/buildnotch"
cp "$src/bin/buildnotch" "$share/buildnotch-run"
chmod +x "$bin/buildnotch" "$share/buildnotch-run"
[ -f "$cfg/config.json" ] || cp "$src/config.example.json" "$cfg/config.json"
echo "Installed. Run 'buildnotch', and add the lines from hyprland.conf to your Hyprland config."
