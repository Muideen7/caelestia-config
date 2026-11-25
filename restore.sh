#!/usr/bin/env bash
# ==============================================================================
# Caelestia Desktop Environment Restore & Setup Script
# ==============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_HOME="$ROOT_DIR/files/home/frontendgeek"
BACKUP_DIR="$HOME/.config/caelestia-backups/backup-$(date +%Y%m%d-%H%M%S)"
DNT_REPO="https://github.com/Muideen7/Caelestia-DNT.git"
DNT_DIR="$HOME/.local/share/caelestia-dnt"
INSTALL_DNT="ask"

for arg in "$@"; do
    case "$arg" in
        --with-dnt) INSTALL_DNT="yes" ;;
        --no-dnt)   INSTALL_DNT="no" ;;
    esac
done

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
backup_if_exists "$HOME/.config/fish/functions"
backup_if_exists "$HOME/.config/fastfetch"
backup_if_exists "$HOME/.local/lib/python3.14/site-packages/sitecustomize.py"

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

# Deploy Python sitecustomize hook (preserves M3 variant on wallpaper changes)
USER_SITE=$(python3 -c "import site; print(site.getusersitepackages())" 2>/dev/null || echo "$HOME/.local/lib/python3.14/site-packages")
mkdir -p "$USER_SITE"
cp -f "$SOURCE_HOME/.local/lib/python3.14/site-packages/sitecustomize.py" "$USER_SITE/" 2>/dev/null || true

# Fix permissions
echo "==> Setting script executable permissions..."
chmod +x "$HOME/.config/caelestia/"*.py "$HOME/.config/caelestia/"*.sh 2>/dev/null || true
chmod +x "$HOME/.local/bin/"* 2>/dev/null || true

echo "==> Reloading running services..."
if command -v hyprctl &>/dev/null; then
    hyprctl reload &>/dev/null || true
fi

systemctl --user daemon-reload 2>/dev/null || true
systemctl --user enable --now caelestia-bridge.service 2>/dev/null || true

if systemctl --user is-active --quiet elephant.service; then
    systemctl --user restart elephant.service || true
fi

if systemctl --user is-active --quiet walker.service; then
    systemctl --user restart walker.service || true
fi

if command -v caelestia &>/dev/null; then
    caelestia shell -r &>/dev/null || true
fi

# Optional Caelestia-DNT browser extension integration (separate repository)
if [ "$INSTALL_DNT" = "ask" ]; then
    if [ -t 0 ]; then
        echo ""
        read -r -p "==> Install optional Caelestia-DNT Chromium browser theme & new tab ($DNT_REPO)? [Y/n] " dnt_reply
        case "${dnt_reply:-Y}" in
            [Nn]*) INSTALL_DNT="no" ;;
            *)     INSTALL_DNT="yes" ;;
        esac
    else
        INSTALL_DNT="no"
    fi
fi

if [ "$INSTALL_DNT" = "yes" ] && command -v git &>/dev/null; then
    echo "==> Setting up optional Caelestia-DNT browser integration..."
    if [ -d "$DNT_DIR/.git" ]; then
        git -C "$DNT_DIR" pull --ff-only || true
    else
        mkdir -p "$(dirname "$DNT_DIR")"
        git clone "$DNT_REPO" "$DNT_DIR" || true
    fi

    if [ -x "$DNT_DIR/install-native-host.sh" ]; then
        bash "$DNT_DIR/install-native-host.sh" || true
    fi
    bash "$HOME/.config/caelestia/dnt-sync.sh" || true
    echo "    To finish in Chrome/Brave/Chromium/Edge/Vivaldi/Thorium:"
    echo "    Open chrome://extensions -> Enable Developer Mode -> Load unpacked -> $DNT_DIR"
else
    echo "==> Skipping Caelestia-DNT (optional). You can clone it manually anytime:"
    echo "    git clone $DNT_REPO $DNT_DIR && bash $DNT_DIR/install-native-host.sh"
fi

echo "==> Restore complete! Everything is up and running."

