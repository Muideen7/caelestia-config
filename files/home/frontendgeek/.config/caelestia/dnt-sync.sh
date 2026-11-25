#!/usr/bin/env bash
# Syncs Caelestia's active Material 3 scheme and wallpaper to optional Caelestia-DNT installs.
# Exits cleanly with 0 if Caelestia-DNT is not installed.
set -euo pipefail

SCHEME="$HOME/.local/state/caelestia/scheme.json"
WP="$HOME/.local/state/caelestia/wallpaper/current"

for dnt_dir in "$HOME/.local/share/caelestia-dnt" "$HOME/Downloads/Project/Caelestia-DNT"; do
    if [ -d "$dnt_dir" ]; then
        [ -f "$SCHEME" ] && cp -f "$SCHEME" "$dnt_dir/caelestia-theme.json" || true
        [ -e "$WP" ] && cp -fL "$WP" "$dnt_dir/wallpaper.jpg" || true
    fi
done
