#!/usr/bin/env bash
# ==============================================================================
# Caelestia Desktop Environment Configuration Installer
# ==============================================================================

set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config/caelestia-backups/backup-$(date +%Y%m%d-%H%M%S)"

echo "==> Installing Caelestia Desktop Configuration..."

# Ensure target directories exist
mkdir -p "$CONFIG_DIR"
mkdir -p "$BACKUP_DIR"

backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "    Backing up existing $(basename "$target") -> $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp -rL "$target" "$BACKUP_DIR/"
    fi
}

echo "==> Backing up existing configurations..."
backup_if_exists "$CONFIG_DIR/quickshell/caelestia"
backup_if_exists "$CONFIG_DIR/caelestia"
backup_if_exists "$CONFIG_DIR/hypr"
backup_if_exists "$CONFIG_DIR/walker/config.toml"
backup_if_exists "$CONFIG_DIR/elephant/elephant.toml"

echo "==> Deploying configuration files..."
mkdir -p "$CONFIG_DIR/quickshell" "$CONFIG_DIR/caelestia" "$CONFIG_DIR/hypr" "$CONFIG_DIR/walker" "$CONFIG_DIR/elephant"

cp -r "$DOTS_DIR/config/quickshell/caelestia" "$CONFIG_DIR/quickshell/"
cp -r "$DOTS_DIR/config/caelestia/"* "$CONFIG_DIR/caelestia/"
cp -r "$DOTS_DIR/config/hypr/"* "$CONFIG_DIR/hypr/"
cp "$DOTS_DIR/config/walker/config.toml" "$CONFIG_DIR/walker/"
cp "$DOTS_DIR/config/elephant/elephant.toml" "$CONFIG_DIR/elephant/"

echo "==> Making scripts executable..."
chmod +x "$CONFIG_DIR/caelestia/"*.py 2>/dev/null || true

echo "==> Reloading running services..."
if command -v hyprctl &>/dev/null; then
    hyprctl reload &>/dev/null || true
fi

if systemctl --user is-active --quiet elephant.service; then
    systemctl --user restart elephant.service || true
fi

if systemctl --user is-active --quiet walker.service; then
    systemctl --user restart walker.service || true
fi

if command -v caelestia &>/dev/null; then
    caelestia shell -r &>/dev/null || true
fi

echo "==> Installation complete! Enjoy your customized Caelestia DE."
