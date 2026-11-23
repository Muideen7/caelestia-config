# 🌌 Caelestia Desktop Configuration

An ultra-modern, dynamic, and aesthetic **Caelestia Desktop Environment** running on **Hyprland** (Arch Linux / CachyOS). Powered by **Quickshell**, **Material You (M3)** theming, and the **Walker + Elephant** launcher suite.

---

## ✨ Features & Custom Extensions

### 🎨 1. Colours & Schemes Suite (`ColourSelect.qml`)
- **Wallpaper 3-Color Harmony**: Automatically derives Primary (active borders & accents), Secondary (icons & interactive controls), and Tertiary (notifications & highlights) directly from the current wallpaper palette.
- **Material 3 Variants**: Instant switching between M3 variants (*Tonal Spot, Vibrant, Expressive, Content, Fidelity, Monochrome, Fruit Salad, Neutral, Rainbow*).
- **Curated Schemes**: Dynamic wallpaper-derived colors, Catppuccin, and Caelestia schemes with live swatches and instant system-wide sync.
- **Dark/Light Mode**: One-click system-wide theme switching.

### 🔄 2. System Updates Page (`UpdatesPage.qml`)
- **Native Package Manager Integration**: Real-time package update checks powered by `paru` and `pacman`.
- **Changelog & Version Comparison**: Shows exact old version &rarr; new version changes with package badges.
- **Actions**:
  - One-click "Check for updates" refresh.
  - "Update All" terminal runner with error handling.
  - Per-package update action.
- **System Maintenance Tools**:
  - Direct benchmark and optimization of Pacman mirrors via `cachyos-rate-mirrors`.
  - Cache cleaner (`paru -Sc`) to free system storage.
  - Dotfiles revision updater (`caelestia update`).

### 🧩 3. Plugins & Extensions Manager (`PluginsPage.qml`)
- **Launcher Provider Control**: Manage all installed **Elephant / Walker** launcher search providers (*Applications, File Search, Clipboard, Calculator, Symbols & Emojis, Terminal Runner, Web Search, To-Do Tasks, Bitwarden, 1Password, etc.*).
- **Category Filtering**: Filter providers by *Core, Productivity, Utilities, Security, Media, and System*.
- **Live Daemon Reloading**: Toggling providers immediately persists changes to `elephant.toml` and safely reloads `elephant.service` and `walker.service`.
- **Custom User Plugins**: Dedicated support for user QML components and scripts placed in `~/.config/caelestia/plugins/`.
- **Dynamic Plugin Counter**: Synchronized loaded plugin count reflected in the Nexus "About" page.

### ⚡ 4. Persistent Bluetooth & Wi-Fi States
- **Reboot Persistence**: Toggling Wi-Fi or Bluetooth off in the **Utility Quick Toggles** or settings pages persistently keeps the radio OFF across reboots.
- **Under the Hood**:
  - **Wi-Fi**: Managed via `nmcli radio wifi`, persisted in NetworkManager state and kernel `rfkill`.
  - **Bluetooth**: Integrated with kernel `rfkill` (`systemd-rfkill.service`) alongside BlueZ D-Bus power states, guaranteeing hardware radios remain disabled even across reboots without unintentional auto-enablement.

### 🖌️ 5. Unified System Theming Pipeline
- **Antigravity IDE**: Color tokens automatically synchronized via `antigravity-theme.py`.
- **KDE & Qt Apps**: Native Kirigami/QQC2 integration via `kde-scheme.py` and `kdeglobals`.
- **Walker Launcher**: GTK4 CSS dynamically regenerated on wallpaper change.
- **SDDM Login Theme**: Synchronized lock screen and login greeter palette.

---

## 📁 Repository Structure

```
caelestia-config/
├── config/
│   ├── quickshell/caelestia/     # Complete Quickshell shell implementation
│   │   ├── modules/
│   │   │   ├── nexus/            # Settings app & dashboard (Nexus)
│   │   │   │   ├── pages/        # Settings pages (UpdatesPage, PluginsPage, etc.)
│   │   │   │   │   ├── wallandstyle/ # ColourSelect & wallpaper options
│   │   │   │   │   ├── UpdatesPage.qml
│   │   │   │   │   ├── PluginsPage.qml
│   │   │   │   │   └── AboutPage.qml
│   │   │   │   └── PageCompRegistry.qml
│   │   │   ├── bar/              # Top taskbar, tray, popouts
│   │   │   ├── utilities/        # Utility panel & quick toggles
│   │   │   ├── lock/             # Lock screen & fingerprint integration
│   │   │   └── launcher/         # Application launcher overlays
│   │   └── services/             # QML system services (Nmcli, Bluetooth, Audio, etc.)
│   ├── caelestia/                # Caelestia CLI & user scripts
│   │   ├── cli.json              # Post-hooks & workspace toggle rules
│   │   ├── shell.json            # Shell feature flags
│   │   ├── hypr-user.lua         # Custom user keybinds & window rules
│   │   ├── hypr-vars.lua         # User variable overrides
│   │   ├── antigravity-theme.py  # Antigravity IDE theme sync
│   │   ├── kde-scheme.py         # KDE / Qt app palette sync
│   │   └── plugins-helper.py     # Elephant launcher plugin daemon helper
│   ├── hypr/                     # Hyprland compositor configuration (Lua)
│   ├── walker/                   # Walker launcher configuration
│   └── elephant/                 # Elephant query daemon configuration
├── install.sh                    # Automated setup script with auto-backups
├── .gitignore
└── README.md
```

---

## 🚀 Installation

### 1. Clone the repository
```bash
git clone https://github.com/Muideen7/caelestia-config.git
cd caelestia-config
```

### 2. Run the installer
```bash
chmod +x install.sh
./install.sh
```
> The installer automatically creates timestamped backups in `~/.config/caelestia-backups/` before deploying any configuration files.

### 3. Dependencies
Ensure you have the following packages installed on Arch/CachyOS:
```bash
paru -S quickshell-git caelestia-cli caelestia-shell hyprland walker elephant-bin
```

---

## ⌨️ Essential Keybindings

| Keybinding | Action |
| :--- | :--- |
| `Super + Space` | Open Walker application & global search |
| `Super + Shift + D` | Open Walker in file search mode |
| `Super + V` | Open clipboard manager with quick-clear option |
| `Super + D` | Toggle communication workspace (WhatsApp / Discord / Equibop) |
| `Alt + Tab` | Smart back-and-forth workspace switcher |
| `Super + N` | Open Nexus Settings (or via Quick Toggles gear icon) |

---

## 📜 License

Distributed under the MIT License. See [LICENSE](config/quickshell/caelestia/LICENSE) for more details.

