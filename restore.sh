#!/usr/bin/env bash
# ==============================================================================
# Caelestia Desktop Environment Restore & Setup Script
# ==============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_HOME="$ROOT_DIR/files/home/frontendgeek"
BACKUP_DIR="$HOME/.config/caelestia-backups/backup-$(date +%Y%m%d-%H%M%S)"

echo "==> Restoring Caelestia Desktop Configuration..."

backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "    Backing up existing $(basename "$target") -> $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp -rL "$target" "$BACKUP_DIR/"
    fi
}

echo "==> Backing up current configs..."
mkdir -p "$BACKUP_DIR"
backup_if_exists "$HOME/.config/caelestia"
backup_if_exists "$HOME/.config/quickshell/caelestia"
backup_if_exists "$HOME/.config/hypr"
backup_if_exists "$HOME/.config/walker/config.toml"
backup_if_exists "$HOME/.config/elephant/elephant.toml"
backup_if_exists "$HOME/.config/fish/functions/fish_greeting.fish"
backup_if_exists "$HOME/.config/fastfetch"

echo "==> Deploying files from snapshot..."
mkdir -p "$HOME/.config/quickshell" \
         "$HOME/.config/caelestia" \
         "$HOME/.config/hypr" \
         "$HOME/.config/walker" \
         "$HOME/.config/elephant" \
         "$HOME/.config/systemd/user" \
         "$HOME/.config/Thunar" \
         "$HOME/.config/fish/functions" \
         "$HOME/.config/fastfetch" \
         "$HOME/.local/bin" \
         "$HOME/.local/share/Thunar/sendto" \
         "$HOME/.local/state/caelestia"

# Copy configurations
cp -r "$SOURCE_HOME/.config/caelestia/"* "$HOME/.config/caelestia/"
cp -r "$SOURCE_HOME/.config/quickshell/caelestia" "$HOME/.config/quickshell/"
cp -r "$SOURCE_HOME/.config/hypr/"* "$HOME/.config/hypr/"
cp "$SOURCE_HOME/.config/walker/config.toml" "$HOME/.config/walker/"
cp "$SOURCE_HOME/.config/elephant/elephant.toml" "$HOME/.config/elephant/"
cp "$SOURCE_HOME/.config/systemd/user/"*.service "$HOME/.config/systemd/user/" 2>/dev/null || true
cp -r "$SOURCE_HOME/.config/Thunar/"* "$HOME/.config/Thunar/" 2>/dev/null || true
cp -r "$SOURCE_HOME/.config/fish/"* "$HOME/.config/fish/" 2>/dev/null || true
cp -r "$SOURCE_HOME/.config/fastfetch/"* "$HOME/.config/fastfetch/" 2>/dev/null || true

# Copy local bin, share & state
cp -r "$SOURCE_HOME/.local/bin/"* "$HOME/.local/bin/" 2>/dev/null || true
cp -r "$SOURCE_HOME/.local/share/Thunar/"* "$HOME/.local/share/Thunar/" 2>/dev/null || true
cp -r "$SOURCE_HOME/.local/state/caelestia/"* "$HOME/.local/state/caelestia/" 2>/dev/null || true

# Fix permissions
echo "==> Setting script executable permissions..."
chmod +x "$HOME/.config/caelestia/"*.py 2>/dev/null || true
chmod +x "$HOME/.local/bin/"* 2>/dev/null || true

echo "==> Reloading running services..."
if command -v hyprctl &>/dev/null; then
    hyprctl reload &>/dev/null || true
fi

systemctl --user daemon-reload 2>/dev/null || true

if systemctl --user is-active --quiet elephant.service; then
    systemctl --user restart elephant.service || true
fi

if systemctl --user is-active --quiet walker.service; then
    systemctl --user restart walker.service || true
fi

if command -v caelestia &>/dev/null; then
    caelestia shell -r &>/dev/null || true
fi

echo "==> Restore complete! Everything is up and running."

