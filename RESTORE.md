# Caelestia / Hyprland Desktop Restore Guide

Snapshot updated: **23 November 2026** (Arch Linux / CachyOS)

`files/` mirrors the original filesystem paths from the host system. Before copying settings back, inspect the files and restore only the components you need.

The included package lists (`packages-explicit.txt` and `packages-foreign.txt`) record the installed packages to help rebuild the underlying desktop environment.

---

## 📂 Source Paths in this Snapshot

### Home Desktop Configuration
- `files/home/frontendgeek/.config/caelestia`: Main CLI hooks (`cli.json`), shell config (`shell.json`), user Hyprland binds (`hypr-user.lua`), user variables (`hypr-vars.lua`), Material You sync scripts (`antigravity-theme.py`, `kde-scheme.py`), launcher plugin manager (`plugins-helper.py`), SDDM templates, and monitor settings.
- `files/home/frontendgeek/.config/quickshell/caelestia`: Complete Quickshell shell suite including:
  - **Nexus Settings**: Custom **Colours & Schemes** (`ColourSelect.qml`), **System Updates** (`UpdatesPage.qml`), **Plugins & Extensions** (`PluginsPage.qml`), and About page integration.
  - **Background & Wallpapers**: Animated wallpaper switching with Material 3 emphasized zoom and crossfade transitions (`Wallpaper.qml`).
  - **Bar & Taskbar**: Workspace markers, active window title, system status icons, and clock.
  - **Utilities & Toggles**: Quick toggles with persistent Wi-Fi and Bluetooth state tracking.
  - **Lock & SDDM**: Lock screen, pam, and biometric integration.
- `files/home/frontendgeek/.config/hypr`: Hyprland configuration (Lua-based modular setup with `hyprland.lua`, `scheme/`, and window rules).
- `files/home/frontendgeek/.config/walker`: Walker GTK4 launcher configuration (`config.toml`).
- `files/home/frontendgeek/.config/elephant`: Elephant query daemon configuration (`elephant.toml`).
- `files/home/frontendgeek/.config/fish`: Fish shell configuration, including `fish_greeting.fish` with dynamic CachyOS ASCII fish logo and redesigned Caelestia banner styled from active palette sequences.
- `files/home/frontendgeek/.config/fastfetch`: Fastfetch system fetch configuration (`config.jsonc`).
- `files/home/frontendgeek/.config/systemd/user`: User systemd service units (`caelestia-bridge.service`, `caelestia-connectd.service`, `elephant.service`, `walker.service`, `udiskie.service`).
- `files/home/frontendgeek/.config/Thunar`: Thunar file manager custom actions (`uca.xml`).
- `files/home/frontendgeek/.local/bin`: User helper scripts (`caelestia-clipboard.sh`, `caelestia-connect*`).
- `files/home/frontendgeek/.local/share/Thunar/sendto`: Thunar "Send To" integrations (`caelestia-connect-sendto.desktop`).
- `files/home/frontendgeek/.local/state/caelestia`: Material You active palette definitions (`scheme.json`, `sequences.txt`, `theme`, `wallpaper`).

---

## 🛠️ Step-by-Step Restoration

### 1. Reinstall Packages
Restore official and AUR packages recorded in the snapshot:
```bash
# Official packages
sudo pacman -S --needed - < packages-explicit.txt

# AUR packages (using paru)
paru -S --needed - < packages-foreign.txt
```

### 2. Restore Configuration Files
You can either run the automated script:
```bash
chmod +x restore.sh
./restore.sh
```

Or manually copy the files into place:
```bash
# Target: ~/.config
cp -r files/home/frontendgeek/.config/caelestia ~/.config/
cp -r files/home/frontendgeek/.config/quickshell/caelestia ~/.config/quickshell/
cp -r files/home/frontendgeek/.config/hypr ~/.config/
cp files/home/frontendgeek/.config/walker/config.toml ~/.config/walker/
cp files/home/frontendgeek/.config/elephant/elephant.toml ~/.config/elephant/
cp -r files/home/frontendgeek/.config/fish ~/.config/
cp -r files/home/frontendgeek/.config/fastfetch ~/.config/
cp files/home/frontendgeek/.config/systemd/user/*.service ~/.config/systemd/user/

# Target: ~/.local
mkdir -p ~/.local/bin ~/.local/state/caelestia
cp -r files/home/frontendgeek/.local/bin/* ~/.local/bin/
cp -r files/home/frontendgeek/.local/state/caelestia/* ~/.local/state/caelestia/

# Ensure executable permissions
chmod +x ~/.config/caelestia/*.py ~/.local/bin/*
```

### 3. Reload Daemons and Services
```bash
systemctl --user daemon-reload
systemctl --user enable --now elephant.service walker.service caelestia-bridge.service
hyprctl reload
caelestia shell -r
```

---

## 🔒 Exclusions & Privacy Notice

The public snapshot intentionally excludes:
- Application secrets, private keys, device certificates (`privateKey.pem`, `certificate.pem`).
- Personal SMS, contacts, and pairing tokens (`~/.config/caelestia-connect/`).
- Local database history, active notification store, and transient image/clipboard caches (`clipboard.gob`, `apps.sqlite`, `notifs.json`).
- Ephemeral socket paths and machine-specific mount configurations.

