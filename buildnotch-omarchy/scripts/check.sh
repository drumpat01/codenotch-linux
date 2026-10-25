#!/bin/sh
# Static checks that work without a Wayland session.
set -eu
cd "$(dirname "$0")/.."
node tests/lib.test.js
node -e 'JSON.parse(require("fs").readFileSync("config.example.json","utf8"))'
if command -v qmllint >/dev/null 2>&1; then qmllint qml/*.qml; else echo "qmllint not installed, skipped"; fi
for f in install.sh bin/buildnotch qml/scripts/sysstat.sh qml/scripts/clip.sh; do sh -n "$f"; done
echo "checks passed"
