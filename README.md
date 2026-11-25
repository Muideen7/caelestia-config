# Muideen's Caelestia Desktop Configuration

Snapshot updated **25 November 2026**. Files under `files/` mirror their original filesystem paths. See [RESTORE.md](RESTORE.md) before copying settings back. The package lists (`packages-explicit.txt` and `packages-foreign.txt`) record the installed package versions.

An ultra-modern, aesthetic **Caelestia Desktop Environment** running on **Hyprland** (Arch Linux / CachyOS). Powered by **Quickshell**, **Material You (M3)** theming, and the **Walker + Elephant** launcher suite.

---

## 🌟 Key Enhancements Beyond Upstream Caelestia Shell

- **Smooth Boot & macOS-Style Unlock Animation (`Wallpaper.qml`, `Background.qml`, `execs.lua`, `hypr-user.lua`)**:
  - Eliminated the post-SDDM white screen flash by overriding Hyprland's compositor `background_color` to dark (`rgb(0d0f14)`) regardless of active light/dark Material 3 scheme.
  - Direct Quickshell launch (`qs -c caelestia -n -d`) in `execs.lua` and synchronous wallpaper instantiation in `Background.qml` for faster login handoff.
  - macOS Sonoma/Sequoia-inspired desktop unlock transition: initial wallpaper renders immediately at full opacity with a `MultiEffect` blur (`0.75 → 0.0`) and subtle zoom settle (`1.07 → 1.0`).
- **Redesigned SDDM Greeter (`files/usr/share/sddm/themes/caelestia/`)**:
  - Top-center hero Date & Clock in `GoogleSansFlex` with subtle vignette and drop shadows for legibility over any wallpaper.
  - Lower-center frosted-glass user card featuring the user avatar, dynamic greeting, OS/Host badges, and a breathing *"Click or press any key"* prompt.
  - Full-screen click-to-unlock support and smooth post-password unlock transition into Hyprland.
- **Colours & Schemes Suite (`ColourSelect.qml`)**:
  - Live Wallpaper 3-Color Harmony: Derives Primary (borders & accents), Secondary (icons & interactive controls), and Tertiary (notifications) directly from the active wallpaper.
  - Smooth Cinematic Wallpaper Transitions: Material 3 emphasized zoom (`1.05 → 1.0`) and crossfade transitions when switching wallpapers.
  - Material 3 Variants & Persistence: Switch between *Tonal Spot, Vibrant, Expressive, Content, Fidelity, Monochrome, Fruit Salad, Neutral, Rainbow*. Your chosen variant (e.g., Expressive) is permanently preserved across wallpaper changes instead of reverting to Tonal Spot (powered by `cli.json` and `sitecustomize.py`).
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
- **Session & Power Menu Fixes**:
  - Configured the **Hibernate** button in the session power menu to cleanly suspend on systems without swap-backed hibernation.
- **Thunar & Caelestia Connect Integration**:
  - Added Thunar **Send To** target and custom context action (*Send to Device via Caelestia Connect*) for seamless file sharing to paired KDE Connect / Caelestia Connect devices.
- **Optional Chromium Browser Theming ([Caelestia-DNT](https://github.com/Muideen7/Caelestia-DNT))**:
  - Separate companion extension repo that syncs your live Material 3 palette & wallpaper to **Chrome, Chromium, Brave, Thorium, Edge, and Vivaldi** (new tab dashboard + YouTube, GitHub, and Reddit site theming).
  - Pre-wired via `caelestia-bridge.service` (`127.0.0.1:39123`) and `dnt-sync.sh` (runs cleanly as a no-op if not installed).
  - Completely optional: `restore.sh` offers to clone & register it by default (`--with-dnt` / `--no-dnt`), or you can clone it manually later.
- **Unified Theming Pipeline**:
  - Syncs desktop Material You colors to **Antigravity IDE** (`antigravity-theme.py`), KDE/Qt apps (`kde-scheme.py`), Walker GTK4 CSS, SDDM lock/login greeter, and optional Caelestia-DNT.
- **Hyprland Overrides (`hypr-user.lua`)**:
  - Smart `Alt + Tab` workspace cycler (remembers normal and special workspaces).
  - Walker launcher keybindings (`Super + Space` for apps, `Super + Shift + D` for files).
  - Enhanced clipboard picker (`Super + V`) with one-click history clearing.
  - Communication workspace toggle (`Super + D` for Whatsie / Discord / Equibop).
- **Terminal Aesthetics & Random Sixel PNG Art Rotation (`fastfetch`, `fish_greeting.fish`)**:
  - Dynamic Sixel image logo rotation in Foot terminal (`fastfetch-PNG` style). On every new terminal instance (and `fastfetch` command), an art PNG is randomly chosen from `~/.config/fastfetch/images/`.
  - Clean boxed system summary card aligned side-by-side with the active art logo (top text banner removed for a minimal, modern aesthetic).

---

## 📂 Repository Structure

```
.
├── files/
│   ├── home/frontendgeek/
│   │   ├── .config/
│   │   │   ├── caelestia/            # CLI config, post-hooks, dnt-sync.sh, user Lua rules, & theme sync scripts
│   │   │   ├── quickshell/caelestia/ # Quickshell shell suite (Nexus, Bar, Utilities, Lock, Wallpaper)
│   │   │   ├── hypr/                 # Hyprland compositor configuration (Lua)
│   │   │   ├── walker/               # Walker GTK4 launcher config
│   │   │   ├── elephant/             # Elephant query daemon config
│   │   │   ├── fish/                 # Interactive shell greeting
│   │   │   ├── fastfetch/            # System fetch configuration & Sixel PNG art rotation
│   │   │   └── systemd/user/         # User systemd service units (bridge, connectd, elephant, walker, udiskie)
│   │   ├── .local/
│   │   │   ├── bin/                  # User scripts (caelestia-clipboard.sh, caelestia-connect*)
│   │   │   ├── lib/                  # Python site customizations (sitecustomize.py preserves M3 variant)
│   │   │   └── state/caelestia/      # Active palette tokens & wallpaper definitions
│   └── usr/share/sddm/themes/caelestia/ # Redesigned SDDM lock-like greeter QML files
├── packages-explicit.txt             # Explicitly installed native packages (pacman -Qqe)
├── packages-foreign.txt              # Foreign/AUR packages installed (pacman -Qqm)
├── restore.sh                        # Automated restore script with backup & optional Caelestia-DNT setup
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

# 3. Restore dotfiles (automatically backs up existing configs & prompts for optional Caelestia-DNT)
chmod +x restore.sh
./restore.sh          # or ./restore.sh --with-dnt / ./restore.sh --no-dnt
```

### Optional: Caelestia-DNT (Chromium Browser Integration)
`Caelestia-DNT` lives in its own repository ([Muideen7/Caelestia-DNT](https://github.com/Muideen7/Caelestia-DNT)) and is **not required** to use this desktop config. If you want Material You theming across **Chrome, Chromium, Brave, Thorium, Edge, or Vivaldi**:

1. Let `./restore.sh` install it automatically, **or** clone it manually anytime:
   ```bash
   git clone https://github.com/Muideen7/Caelestia-DNT.git ~/.local/share/caelestia-dnt
   bash ~/.local/share/caelestia-dnt/install-native-host.sh
   ```
2. In your Chromium browser, open `chrome://extensions` (or `brave://extensions`), enable **Developer mode**, click **Load unpacked**, and select `~/.local/share/caelestia-dnt`.

---

## 🔒 Privacy & Exclusions

Personal notes, SMS, contacts, browser history, runtime application databases (`apps.sqlite`), transient caches (`clipboard.gob`), and private keys/certificates are kept out of this Git snapshot.

---

## 📜 License

Distributed under the MIT License. See [LICENSE](files/home/frontendgeek/.config/quickshell/caelestia/LICENSE) for details.
