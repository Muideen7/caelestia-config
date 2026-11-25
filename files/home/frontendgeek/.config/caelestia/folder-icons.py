#!/usr/bin/env python3
"""
Generate a user-space Papirus folder icon theme (~/.local/share/icons/Caelestia-Folders)
whose folder colors dynamically match Caelestia's active Material 3 scheme.
Inherits all non-folder icons from Papirus-Light / Papirus-Dark based on mode.
"""
import configparser
import json
import os
import pathlib
import subprocess

HOME = pathlib.Path.home()
SCHEME_PATH = HOME / ".local/state/caelestia/scheme.json"
PAPIRUS_DIR = pathlib.Path("/usr/share/icons/Papirus")
OUT_DIR = HOME / ".local/share/icons/Caelestia-Folders"
SIZES = ["16x16", "22x22", "24x24", "32x32", "48x48", "64x64"]


def _hex_clean(val: str, fallback: str) -> str:
    val = (val or fallback).strip().lstrip("#")
    return val if len(val) == 6 else fallback


def _darken(hex_str: str, factor: float = 0.78) -> str:
    r = max(0, min(255, int(int(hex_str[0:2], 16) * factor)))
    g = max(0, min(255, int(int(hex_str[2:4], 16) * factor)))
    b = max(0, min(255, int(int(hex_str[4:6], 16) * factor)))
    return f"{r:02x}{g:02x}{b:02x}"


def generate_icons() -> None:
    if not SCHEME_PATH.exists() or not PAPIRUS_DIR.is_dir():
        return

    data = json.loads(SCHEME_PATH.read_text())
    mode = data.get("mode", "dark")
    colours = data.get("colours", {})

    primary = _hex_clean(colours.get("primary"), "82aefe")
    primary_back = _darken(primary, 0.78)
    on_primary = _hex_clean(colours.get("onPrimary"), "1d344f")

    secondary = _hex_clean(colours.get("secondary"), "607d8b")
    secondary_back = _darken(secondary, 0.78)
    on_secondary = _hex_clean(colours.get("onSecondary"), "222c31")

    paper = _hex_clean(colours.get("surfaceContainerLowest"), "e4e4e4")

    # Case-insensitive replacement map from Papirus blue/grey-blue tokens to M3
    replacements = {
        "#5294e2": f"#{primary}",
        "#4877b1": f"#{primary_back}",
        "#1d344f": f"#{on_primary}",
        "#607d8b": f"#{secondary}",
        "#4d646f": f"#{secondary_back}",
        "#222c31": f"#{on_secondary}",
        "#e4e4e4": f"#{paper}",
    }

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    inherit_theme = "Papirus-Dark" if mode == "dark" else "Papirus-Light"

    dirs_list = ",".join(f"{s}/places" for s in SIZES)
    index_lines = [
        "[Icon Theme]",
        "Name=Caelestia-Folders",
        "Comment=Dynamic Material You Papirus folders synced with Caelestia",
        f"Inherits={inherit_theme}",
        f"Directories={dirs_list}",
        "",
    ]
    for s in SIZES:
        px = s.split("x")[0]
        index_lines.extend([
            f"[{s}/places]",
            f"Context=Places",
            f"Size={px}",
            "Type=Fixed",
            "",
        ])
    (OUT_DIR / "index.theme").write_text("\n".join(index_lines))

    for size in SIZES:
        src_places = PAPIRUS_DIR / size / "places"
        dst_places = OUT_DIR / size / "places"
        if not src_places.is_dir():
            continue
        dst_places.mkdir(parents=True, exist_ok=True)

        # Pass 1: Recolor regular folder-blue* / user-blue* SVGs
        for entry in src_places.iterdir():
            if not entry.is_symlink() and entry.is_file() and entry.suffix == ".svg":
                if entry.name.startswith(("folder-blue", "user-blue")):
                    svg = entry.read_text(errors="ignore")
                    for old_hex, new_hex in replacements.items():
                        svg = svg.replace(old_hex, new_hex).replace(old_hex.upper(), new_hex)
                    (dst_places / entry.name).write_text(svg)

        # Pass 2: Recreate symlinks that resolve to folder-blue* / user-blue* / folder.svg
        for entry in src_places.iterdir():
            if entry.is_symlink() and entry.suffix == ".svg":
                target = os.readlink(entry)
                if "blue" in target or entry.name in ("inode-directory.svg", "folder.svg") or target == "folder.svg":
                    dst_link = dst_places / entry.name
                    if dst_link.exists() or dst_link.is_symlink():
                        dst_link.unlink()
                    dst_link.symlink_to(target)

    # Refresh GTK icon cache
    subprocess.run(["gtk-update-icon-cache", "-f", "-t", str(OUT_DIR)], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)

    # Point GTK3, GTK4, qtengine, and gsettings to Caelestia-Folders
    for gtk_ini in (HOME / ".config/gtk-3.0/settings.ini", HOME / ".config/gtk-4.0/settings.ini"):
        if gtk_ini.exists():
            cp = configparser.ConfigParser()
            cp.read(gtk_ini)
            if "Settings" in cp:
                cp["Settings"]["gtk-icon-theme-name"] = "Caelestia-Folders"
                with gtk_ini.open("w") as f:
                    cp.write(f)

    qt_cfg = HOME / ".config/qtengine/config.json"
    if qt_cfg.exists():
        try:
            qdata = json.loads(qt_cfg.read_text())
            qdata.setdefault("theme", {})["iconTheme"] = "Caelestia-Folders"
            qt_cfg.write_text(json.dumps(qdata, indent=4))
        except Exception:
            pass

    subprocess.run(
        ["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", "Caelestia-Folders"],
        stderr=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
    )


if __name__ == "__main__":
    generate_icons()
