#!/bin/sh
# Install Ledge for the current user (no root needed). Use --uninstall to remove.
set -eu
src="$(cd "$(dirname "$0")" && pwd)"
share="${XDG_DATA_HOME:-$HOME/.local/share}/ledge-app"
bin="$HOME/.local/bin"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}/ledge"

if [ "${1:-}" = "--uninstall" ]; then
    rm -rf "$share" "$bin/ledge"
    echo "Removed. Config in $cfg and data in ${XDG_DATA_HOME:-$HOME/.local/share}/ledge were kept."
    exit 0
fi

command -v quickshell >/dev/null 2>&1 || {
    echo "quickshell not found. Install deps: sudo pacman -S --needed quickshell libnotify github-cli" >&2
    exit 1
}
mkdir -p "$share" "$bin" "$cfg"
rm -rf "$share/qml"
cp -r "$src/qml" "$share/qml"
printf '#!/bin/sh\nLEDGE_DIR="%s" exec "%s/ledge-run" "$@"\n' "$share" "$share" > "$bin/ledge"
cp "$src/bin/ledge" "$share/ledge-run"
chmod +x "$bin/ledge" "$share/ledge-run"
[ -f "$cfg/config.json" ] || cp "$src/config.example.json" "$cfg/config.json"
echo "Installed. Run 'ledge', and add the lines from hyprland.conf to your Hyprland config."
