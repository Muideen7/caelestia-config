# Muideen's Caelestia Desktop Configuration

Snapshot updated **23 November 2026**. Files under `files/` mirror their original filesystem paths. See [RESTORE.md](RESTORE.md) before copying settings back. The package lists (`packages-explicit.txt` and `packages-foreign.txt`) record the installed package versions.

An ultra-modern, aesthetic **Caelestia Desktop Environment** running on **Hyprland** (Arch Linux / CachyOS). Powered by **Quickshell**, **Material You (M3)** theming, and the **Walker + Elephant** launcher suite.

---

## 🌟 Key Highlights & Custom Enhancements

- **Colours & Schemes Suite (`ColourSelect.qml`)**:
  - Live Wallpaper 3-Color Harmony: Derives Primary (borders & accents), Secondary (icons & interactive controls), and Tertiary (notifications) directly from the active wallpaper.
  - Smooth Cinematic Wallpaper Transitions: Material 3 emphasized zoom (`1.05 → 1.0`) and crossfade transitions when switching wallpapers.
  - Material 3 Variants: Switch between *Tonal Spot, Vibrant, Expressive, Content, Fidelity, Monochrome, Fruit Salad, Neutral, Rainbow*.
  - Curated Schemes: Dynamic Material You, Catppuccin, and Caelestia presets with live color swatches.
- **System Updates Page (`UpdatesPage.qml`)**:
  - Real-time system update monitoring powered by `paru` and `pacman`.
  - Detailed version changelog view (`old_ver → new_ver`), single package upgrade, full system upgrade runner, and mirror speed optimization (`cachyos-rate-mirrors`).
- **Plugins & Extensions Manager (`PluginsPage.qml`)**:
  - Full control over all installed **Elephant / Walker** launcher search providers (*Applications, File Search, Clipboard, Calculator, Symbols & Emojis, Runner, Web Search, To-Do Tasks, Bitwarden, etc.*).
  - Categorized provider filtering (*Core, Productivity, Utilities, Security, Media, System*).
  - Background daemon script (`plugins-helper.py`) that instantly persists changes to `elephant.toml` and restarts launcher services.
  - Support for custom user scripts and QML extensions in `~/.config/caelestia/plugins/`.
- **Persistent Bluetooth & Wi-Fi States**:
  - Toggling Wi-Fi or Bluetooth in the **Utility Quick Toggles** or settings persistently stays OFF across full system reboots using kernel `rfkill` + NetworkManager state tracking.
- **Unified Theming Pipeline**:
  - Syncs desktop Material You colors to **Antigravity IDE** (`antigravity-theme.py`), KDE/Qt apps (`kde-scheme.py`), Walker GTK4 CSS, and SDDM lock/login greeter.
- **Hyprland Overrides (`hypr-user.lua`)**:
  - Smart `Alt + Tab` workspace cycler (remembers normal and special workspaces).
  - Walker launcher keybindings (`Super + Space` for apps, `Super + Shift + D` for files).
  - Enhanced clipboard picker (`Super + V`) with one-click history clearing.
  - Communication workspace toggle (`Super + D` for WhatsApp / Discord / Equibop).
- **Terminal Aesthetics & Greeting (`fish_greeting.fish`, `fastfetch`)**:
  - Dynamic CachyOS ASCII art logo matching the active Material You scheme (using terminal OSC 4 sequences `$c1`, `$c2`, `$c3` from `~/.local/state/caelestia/sequences.txt`).
  - Redesigned futuristic, slant Caelestia banner with horizontal gradient transitions.
  - Integrated Fastfetch system summary aligned directly beneath the banner.

---

## 📂 Repository Structure

```
.
├── files/
│   └── home/frontendgeek/
│       ├── .config/
│       │   ├── caelestia/            # CLI config, post-hooks, user Lua rules, & theme sync scripts
│       │   ├── quickshell/caelestia/ # Quickshell shell suite (Nexus, Bar, Utilities, Lock)
│       │   ├── hypr/                 # Hyprland compositor configuration (Lua)
│       │   ├── walker/               # Walker GTK4 launcher config
│       │   ├── elephant/             # Elephant query daemon config
│       │   ├── fish/                 # Interactive shell greeting with dynamic CachyOS ASCII logo
│       │   ├── fastfetch/            # System fetch configuration aligned to greeting banner
│       │   └── systemd/user/         # User systemd service units
│       ├── .local/
│       │   ├── bin/                  # User scripts (caelestia-clipboard.sh, caelestia-connect*)
│       │   └── state/caelestia/      # Active palette tokens & wallpaper definitions
├── packages-explicit.txt             # Explicitly installed native packages (pacman -Qqe)
├── packages-foreign.txt              # Foreign/AUR packages installed (pacman -Qqm)
├── restore.sh                        # Automated restore script with backup support
├── RESTORE.md                        # Restoration and path mapping guide
├── .gitignore
└── README.md
```

---

## 🚀 Quick Restore

```bash
# 1. Clone repository
git clone https://github.com/Muideen7/caelestia-config.git
cd caelestia-config

# 2. Reinstall packages
sudo pacman -S --needed - < packages-explicit.txt
paru -S --needed - < packages-foreign.txt

# 3. Restore dotfiles (automatically creates backups of existing configs)
chmod +x restore.sh
./restore.sh
```

---

## 🔒 Privacy & Exclusions

Personal notes, SMS, contacts, browser history, runtime application databases (`apps.sqlite`), transient caches (`clipboard.gob`), and private keys/certificates are kept out of this Git snapshot.

---

## 📜 License

Distributed under the MIT License. See [LICENSE](files/home/frontendgeek/.config/quickshell/caelestia/LICENSE) for details.
