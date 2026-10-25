#!/bin/sh
# Clipboard history through cliphist + wl-clipboard (Omarchy ships both).
#   clip.sh list | text ID | copy ID | delete ID | image ID   (image prints a temp file path)
set -u
cmd="${1:-list}"
id="${2:-}"
case "$id" in ''|*[!0-9]*) [ "$cmd" = list ] || { echo "bad id" >&2; exit 2; } ;; esac
cache="${XDG_RUNTIME_DIR:-/tmp}/buildnotch-clips"
case "$cmd" in
    list)   exec cliphist list ;;
    text)   cliphist list | grep -m1 "^$id	" | cliphist decode ;;
    copy)   cliphist list | grep -m1 "^$id	" | cliphist decode | wl-copy ;;
    delete) cliphist list | grep -m1 "^$id	" | cliphist delete ;;
    image)  mkdir -p "$cache"
            f="$cache/$id.img"
            [ -s "$f" ] || { cliphist list | grep -m1 "^$id	" | cliphist decode > "$f"; }
            echo "$f" ;;
    *) echo "usage: clip.sh list|text|copy|delete|image [ID]" >&2; exit 2 ;;
esac
