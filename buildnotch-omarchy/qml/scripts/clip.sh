#!/bin/sh
# Clipboard history through cliphist + wl-clipboard (Omarchy ships both).
#   clip.sh list | text ID | copy ID | delete ID | image ID   (image prints a temp file path)
set -u
cmd="${1:-list}"
id="${2:-}"
case "$id" in ''|*[!0-9]*) [ "$cmd" = list ] || { echo "bad id" >&2; exit 2; } ;; esac
cache="${XDG_RUNTIME_DIR:-/tmp}/buildnotch-clips"
case "$cmd" in
    list)   command -v cliphist >/dev/null 2>&1 || exit 127
            out="$(cliphist list 2>/dev/null)" || out=""
            # Empty history and no watcher: nothing is recording the clipboard (exit 3).
            if [ -z "$out" ] && ! pgrep -f 'wl-paste.*cliphist store' >/dev/null 2>&1; then exit 3; fi
            [ -z "$out" ] || printf '%s\n' "$out" ;;
    text)   cliphist list | grep -m1 "^$id	" | cliphist decode ;;
    copy)   cliphist list | grep -m1 "^$id	" | cliphist decode | wl-copy ;;
    delete) cliphist list | grep -m1 "^$id	" | cliphist delete ;;
    image)  mkdir -p "$cache"
            f="$cache/$id.img"
            [ -s "$f" ] || { cliphist list | grep -m1 "^$id	" | cliphist decode > "$f"; }
            echo "$f" ;;
    *) echo "usage: clip.sh list|text|copy|delete|image [ID]" >&2; exit 2 ;;
esac
