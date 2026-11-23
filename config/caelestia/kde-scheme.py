#!/usr/bin/env python3
"""Make KDE/Kirigami and GTK apps follow Caelestia's theme and mode.

Caelestia regenerates ~/.config/qtengine/caelestia.colors (a complete KDE colour
scheme, but in *hex*) every time the wallpaper/scheme changes.  Qt/KDE apps only
read KDE colour schemes in *decimal* r,g,b form from either:
    ~/.local/share/color-schemes/<Name>.colors
    ~/.config/kdeglobals  ([Colors:*] sections + [General] ColorScheme)

This script:
1. Converts Caelestia's scheme and installs it in both places, notifying KDE apps.
2. Synchronizes GTK3/GTK4 light/dark themes (adw-gtk3 vs adw-gtk3-dark), icon themes,
   and settings.ini so GTK applications seamlessly match the light/dark mode.
"""

import json
import os
import pathlib
import re
import subprocess
import sys

HOME = pathlib.Path.home()
SRC = HOME / ".config/qtengine/caelestia.colors"
COLOR_SCHEMES = HOME / ".local/share/color-schemes"
SCHEME_OUT = COLOR_SCHEMES / "Caelestia.colors"
KDEGLOBALS = HOME / ".config/kdeglobals"
QTENGINE_CFG = HOME / ".config/qtengine/config.json"
SCHEME_JSON = HOME / ".local/state/caelestia/scheme.json"


def hex_to_decimal(match: "re.Match") -> str:
    h = match.group(1)
    return ",".join(str(int(h[i:i + 2], 16)) for i in (0, 2, 4))


def preserved_sections(text: str) -> list[tuple[str, list[str]]]:
    """Keep non-colour sections so we never clobber unrelated KDE settings."""
    sections: list[tuple[str, list[str]]] = []
    current: list[str] | None = None
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            name = stripped[1:-1]
            if name.startswith(("Colors:", "ColorEffects:")) or name in ("General", "KDE", "WM"):
                current = None
                continue
            current = [name, []]
            sections.append((name, current[1]))
        elif current is not None:
            current[1].append(line)
    return sections


def sync_gtk(mode: str, icon_theme: str | None = None) -> None:
    """Synchronize GTK settings for both GTK3 and GTK4 apps."""
    is_dark = mode == "dark"
    gtk_theme = "adw-gtk3-dark" if is_dark else "adw-gtk3"
    gtk_icon_theme = icon_theme if icon_theme else f"Papirus-{'Dark' if is_dark else 'Light'}"
    color_scheme = "prefer-dark" if is_dark else "prefer-light"
    prefer_dark_val = "1" if is_dark else "0"

    # 1. Update dconf
    for key, val in [
        ("/org/gnome/desktop/interface/gtk-theme", f"'{gtk_theme}'"),
        ("/org/gnome/desktop/interface/icon-theme", f"'{gtk_icon_theme}'"),
        ("/org/gnome/desktop/interface/color-scheme", f"'{color_scheme}'"),
    ]:
        subprocess.run(["dconf", "write", key, val], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    # 2. Update gsettings
    for key, val in [
        ("gtk-theme", gtk_theme),
        ("icon-theme", gtk_icon_theme),
        ("color-scheme", color_scheme),
    ]:
        subprocess.run(
            ["gsettings", "set", "org.gnome.desktop.interface", key, val],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    # 3. Update settings.ini for gtk-3.0 and gtk-4.0
    for gtk_ver in ["gtk-3.0", "gtk-4.0"]:
        ini_dir = HOME / ".config" / gtk_ver
        ini_dir.mkdir(parents=True, exist_ok=True)
        ini_file = ini_dir / "settings.ini"

        lines: list[str] = []
        if ini_file.exists():
            for line in ini_file.read_text().splitlines():
                if not any(
                    line.strip().startswith(prefix)
                    for prefix in [
                        "gtk-theme-name",
                        "gtk-icon-theme-name",
                        "gtk-application-prefer-dark-theme",
                    ]
                ):
                    lines.append(line)

        if not any(l.strip() == "[Settings]" for l in lines):
            lines.insert(0, "[Settings]")

        settings_idx = next(i for i, l in enumerate(lines) if l.strip() == "[Settings]")
        lines.insert(settings_idx + 1, f"gtk-application-prefer-dark-theme = {prefer_dark_val}")
        lines.insert(settings_idx + 1, f"gtk-icon-theme-name = {gtk_icon_theme}")
        lines.insert(settings_idx + 1, f"gtk-theme-name = {gtk_theme}")

        ini_file.write_text("\n".join(lines).strip() + "\n")

    # 4. Update xsettingsd if directory exists or if config used
    xsettings_dir = HOME / ".config/xsettingsd"
    xsettings_conf = xsettings_dir / "xsettingsd.conf"
    if xsettings_dir.exists():
        xsettings_conf.write_text(
            f'Net/ThemeName "{gtk_theme}"\n'
            f'Net/IconThemeName "{gtk_icon_theme}"\n'
            f'Gtk/ApplicationPreferDarkTheme {prefer_dark_val}\n'
        )



def sync_browser_extension() -> None:
    """Sync active scheme, transparency, and wallpaper to Caelestia Dynamic New Tab extension."""
    import shutil
    candidate_dirs = [
        HOME / 'Downloads/Project/Caelestia-DNT',
        HOME / '.config/caelestia/caelestia-dnt',
        HOME / '.local/share/caelestia-dnt',
        HOME / 'Downloads/Project/caelestia-newtab',
    ]
    ext_dirs = [d for d in candidate_dirs if d.exists()]
    if not ext_dirs:
        return

    transparency = True
    shell_json = HOME / '.config/caelestia/shell.json'
    if shell_json.exists():
        try:
            s_data = json.loads(shell_json.read_text())
            transparency = s_data.get('appearance', {}).get('transparency', {}).get('enabled', True)
        except Exception:
            pass

    wp_current = HOME / '.local/state/caelestia/wallpaper/current'
    if wp_current.exists():
        try:
            for ed in ext_dirs:
                shutil.copyfile(str(wp_current.resolve()), str(ed / 'wallpaper.jpg'))
        except Exception:
            pass

    if SCHEME_JSON.exists():
        try:
            t_data = json.loads(SCHEME_JSON.read_text())
            t_data['transparency'] = transparency
            t_data['username'] = 'FrontendGeek'
            for ed in ext_dirs:
                (ed / 'caelestia-theme.json').write_text(json.dumps(t_data))
        except Exception:
            pass
def main() -> int:
    mode = os.environ.get("SCHEME_MODE")
    if not mode and SCHEME_JSON.exists():
        try:
            mode = json.loads(SCHEME_JSON.read_text()).get("mode")
        except Exception:
            pass
    if not mode:
        mode = "dark"

    icon_theme = None
    try:
        icon_theme = json.loads(QTENGINE_CFG.read_text())["theme"].get("iconTheme")
    except Exception:
        pass

    # Synchronize GTK settings
    sync_gtk(mode, icon_theme)
    sync_browser_extension()

    if not SRC.exists():
        print(f"{SRC} not found; skipping KDE color scheme", file=sys.stderr)
        return 0

    scheme = re.sub(r"#([0-9a-fA-F]{6})", hex_to_decimal, SRC.read_text())

    COLOR_SCHEMES.mkdir(parents=True, exist_ok=True)
    SCHEME_OUT.write_text(scheme)

    other = preserved_sections(KDEGLOBALS.read_text()) if KDEGLOBALS.exists() else []

    parts: list[str] = [scheme.rstrip(), "", "[Icons]"]
    if icon_theme:
        parts.append(f"Theme={icon_theme}")
    for name, lines in other:
        parts += ["", f"[{name}]", *lines]

    KDEGLOBALS.write_text("\n".join(parts).strip() + "\n")

    # Ask running KDE/Qt apps to re-read the global colour scheme.
    try:
        subprocess.run(
            [
                "dbus-send", "--session", "--type=signal", "/KGlobalSettings",
                "org.kde.KGlobalSettings.notifyChange", "int32:0", "int32:0",
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=5,
        )
    except Exception:
        pass

    print(f"Installed Caelestia KDE and GTK schemes (mode={mode}, iconTheme={icon_theme})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
