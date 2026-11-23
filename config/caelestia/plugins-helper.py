#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    tomllib = None

ELEPHANT_CONF = Path.home() / ".config" / "elephant" / "elephant.toml"
ELEPHANT_PROVIDERS = Path.home() / ".config" / "elephant" / "providers"
CAELESTIA_PLUGINS = Path.home() / ".config" / "caelestia" / "plugins"

PROVIDER_METADATA = {
    "desktopapplications": {"name": "Applications", "desc": "Launch installed desktop applications", "icon": "apps", "category": "Core"},
    "files": {"name": "File Search", "desc": "Search local files and directories", "icon": "folder", "category": "Core"},
    "clipboard": {"name": "Clipboard Manager", "desc": "Search and paste from clipboard history", "icon": "content_paste", "category": "Productivity"},
    "calc": {"name": "Calculator", "desc": "Solve math expressions and unit conversions", "icon": "calculate", "category": "Utilities"},
    "symbols": {"name": "Symbols & Emojis", "desc": "Search unicode symbols, nerd fonts, and emojis", "icon": "sentiment_satisfied", "category": "Utilities"},
    "runner": {"name": "Command Runner", "desc": "Execute terminal commands directly", "icon": "terminal", "category": "Development"},
    "websearch": {"name": "Web Search", "desc": "Quickly query web search engines", "icon": "travel_explore", "category": "Internet"},
    "todo": {"name": "To-Do Tasks", "desc": "Quick task management and checklist", "icon": "check_box", "category": "Productivity"},
    "archlinuxpkgs": {"name": "Arch Packages", "desc": "Search Arch & AUR package repositories", "icon": "inventory_2", "category": "System"},
    "bluetooth": {"name": "Bluetooth Devices", "desc": "Quickly connect and toggle bluetooth devices", "icon": "bluetooth", "category": "Connectivity"},
    "wireplumber": {"name": "Audio Control", "desc": "Volume control and audio sink switching", "icon": "volume_up", "category": "Media"},
    "playerctl": {"name": "Media Player", "desc": "Control active media playback and MPRIS", "icon": "play_circle", "category": "Media"},
    "windows": {"name": "Window Switcher", "desc": "List and switch between open windows", "icon": "web_stories", "category": "Core"},
    "bitwarden": {"name": "Bitwarden", "desc": "Search credentials and logins securely", "icon": "security", "category": "Security"},
    "1password": {"name": "1Password", "desc": "1Password vault integration", "icon": "key", "category": "Security"},
    "protonpass": {"name": "Proton Pass", "desc": "Proton Pass vault integration", "icon": "password", "category": "Security"},
    "bookmarks": {"name": "Browser Bookmarks", "desc": "Search browser bookmarks and history", "icon": "bookmark", "category": "Internet"},
    "snippets": {"name": "Text Snippets", "desc": "Quick boilerplate and text snippets", "icon": "short_text", "category": "Productivity"},
    "unicode": {"name": "Unicode Table", "desc": "Browse and search unicode character codes", "icon": "font_download", "category": "Utilities"},
    "menus": {"name": "System Menus", "desc": "Application action menus and submenus", "icon": "menu", "category": "System"},
    "providerlist": {"name": "Provider Selector", "desc": "Search launcher provider list", "icon": "list", "category": "Launcher"}
}

def get_ignored_providers() -> set:
    if not ELEPHANT_CONF.exists():
        return set()
    try:
        if tomllib:
            with open(ELEPHANT_CONF, "rb") as f:
                data = tomllib.load(f)
                return set(data.get("ignored_providers", []))
        else:
            content = ELEPHANT_CONF.read_text()
            m = re.search(r'ignored_providers\s*=\s*\[(.*?)\]', content, re.DOTALL)
            if m:
                items = [x.strip().strip('"\'') for x in m.group(1).split(",") if x.strip()]
                return set(items)
    except Exception:
        pass
    return set()

def set_ignored_providers(ignored: set):
    ELEPHANT_CONF.parent.mkdir(parents=True, exist_ok=True)
    items_str = ", ".join(f'"{x}"' for x in sorted(ignored))
    new_line = f"ignored_providers = [{items_str}]"
    
    if not ELEPHANT_CONF.exists():
        ELEPHANT_CONF.write_text(new_line + "\n")
        return

    content = ELEPHANT_CONF.read_text()
    if re.search(r'ignored_providers\s*=\s*\[.*?\]', content, re.DOTALL):
        updated = re.sub(r'ignored_providers\s*=\s*\[.*?\]', new_line, content, flags=re.DOTALL)
    else:
        updated = new_line + "\n" + content
    ELEPHANT_CONF.write_text(updated)

def get_all_plugins():
    ignored = get_ignored_providers()
    plugins = []

    # Check Elephant providers
    if ELEPHANT_PROVIDERS.exists():
        for f in sorted(ELEPHANT_PROVIDERS.glob("*.so")):
            pid = f.stem.lower()
            # Skip distros other than arch
            if pid in ("aptpackages", "dnfpackages", "niri", "nirisessions", "niriactions"):
                continue
            meta = PROVIDER_METADATA.get(pid, {
                "name": pid.capitalize(),
                "desc": f"Elephant launcher provider ({f.name})",
                "icon": "extension",
                "category": "Provider"
            })
            plugins.append({
                "id": pid,
                "name": meta["name"],
                "description": meta["desc"],
                "icon": meta["icon"],
                "category": meta["category"],
                "enabled": pid not in ignored,
                "type": "launcher_provider",
                "file": str(f)
            })

    # Check user custom plugins in ~/.config/caelestia/plugins
    CAELESTIA_PLUGINS.mkdir(parents=True, exist_ok=True)
    for p in sorted(CAELESTIA_PLUGINS.iterdir()):
        if p.name.startswith("."):
            continue
        plugins.append({
            "id": p.name,
            "name": p.stem.replace("-", " ").title(),
            "description": f"Custom user plugin ({p.name})",
            "icon": "tune",
            "category": "User Plugin",
            "enabled": True,
            "type": "custom",
            "file": str(p)
        })

    return plugins

def main():
    if len(sys.argv) < 2 or sys.argv[1] == "list":
        print(json.dumps(get_all_plugins(), indent=2))
    elif sys.argv[1] == "count":
        plugins = get_all_plugins()
        active = sum(1 for p in plugins if p["enabled"])
        print(active)
    elif sys.argv[1] == "toggle" and len(sys.argv) >= 3:
        target = sys.argv[2].lower()
        ignored = get_ignored_providers()
        if target in ignored:
            ignored.remove(target)
            new_state = True
        else:
            ignored.add(target)
            new_state = False
        set_ignored_providers(ignored)
        # Restart services in background
        subprocess.run(["systemctl", "--user", "restart", "elephant.service", "walker.service"], capture_output=True)
        print(json.dumps({"success": True, "id": target, "enabled": new_state}))
    else:
        print("Usage: plugins-helper.py [list|count|toggle <id>]")

if __name__ == "__main__":
    main()
