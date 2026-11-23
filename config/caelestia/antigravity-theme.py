#!/usr/bin/env python3
"""Sync Caelestia dynamic Material You theme to Antigravity IDE (VS Code).

Reads ~/.local/state/caelestia/scheme.json and updates Antigravity IDE's
User/settings.json as well as a local theme extension so the IDE matches
the desktop shell in real-time.
"""

import json
import pathlib
import sys

HOME = pathlib.Path.home()
SCHEME_FILE = HOME / ".local/state/caelestia/scheme.json"
ANTIGRAVITY_SETTINGS = HOME / ".config/Antigravity IDE/User/settings.json"
VSCODIUM_SETTINGS = HOME / ".config/VSCodium/User/settings.json"
EXT_DIR = HOME / ".antigravity-ide/extensions/caelestia-theme"
VSCODIUM_EXT_DIR = HOME / ".vscode-oss/extensions/caelestia-theme"
THEME_JSON = EXT_DIR / "themes/caelestia.json" 


def hex_color(val: str) -> str:
    val = val.strip().lstrip("#")
    return f"#{val}"


def hex_with_alpha(val: str, alpha: str) -> str:
    val = val.strip().lstrip("#")
    return f"#{val}{alpha}"


def build_theme_tokens(colors: dict[str, str], mode: str) -> tuple[dict, dict]:
    c = {k: hex_color(v) for k, v in colors.items()}
    is_dark = mode == "dark"

    # Fallbacks if some palette keys are missing
    bg = c.get("background", "#130c0c" if is_dark else "#fff8f7")
    surface = c.get("surface", bg)
    surf_low = c.get("surfaceContainerLow", "#1a1110" if is_dark else "#fff0ef")
    surf_mid = c.get("surfaceContainer", "#221716" if is_dark else "#fee9e7")
    surf_high = c.get("surfaceContainerHigh", "#281d1c" if is_dark else "#f9e3e1")
    surf_highest = c.get("surfaceContainerHighest", "#302221" if is_dark else "#f3ddd8")
    surf_dim = c.get("surfaceDim", bg)
    surf_bright = c.get("surfaceBright", surf_highest)

    on_surface = c.get("onSurface", "#f9e0de" if is_dark else "#3e2f2e")
    on_surf_var = c.get("onSurfaceVariant", "#bca6a4" if is_dark else "#84716f")
    outline = c.get("outline", "#84716f" if is_dark else "#8a7675")
    outline_var = c.get("outlineVariant", "#544443" if is_dark else "#d4c4c2")

    primary = c.get("primary", "#f9b6b1" if is_dark else "#a86561")
    on_primary = c.get("onPrimary", "#613331" if is_dark else "#fff7f6")
    prim_container = c.get("primaryContainer", "#764542" if is_dark else "#ffdbd8")
    on_prim_container = c.get("onPrimaryContainer", "#ffdbd8" if is_dark else "#613331")

    secondary = c.get("secondary", "#e7bdb9" if is_dark else "#785755")
    on_secondary = c.get("onSecondary", "#563937" if is_dark else "#fff7f6")
    sec_container = c.get("secondaryContainer", "#503432" if is_dark else "#ffdad7")

    tertiary = c.get("tertiary", "#ffd9b0" if is_dark else "#7d5829")
    on_tertiary = c.get("onTertiary", "#6c491b" if is_dark else "#fff7f3")

    error = c.get("error", "#f97758" if is_dark else "#a73b21")
    on_error = c.get("onError", "#450900" if is_dark else "#ffffff")

    green = c.get("green", "#ffd8c5" if is_dark else "#40a02b")
    yellow = c.get("yellow", "#ffede9" if is_dark else "#df8e1d")
    peach = c.get("peach", "#ffbeb3" if is_dark else "#fe640b")
    blue = c.get("blue", "#ffa1c2" if is_dark else "#1e66f5")
    mauve = c.get("mauve", "#ffa8b7" if is_dark else "#8839ef")
    teal = c.get("teal", "#ffdb94" if is_dark else "#179299")

    # Workbench color customizations
    workbench = {
        # Base colors
        "focusBorder": primary,
        "foreground": on_surface,
        "disabledForeground": hex_with_alpha(outline, "80"),
        "widget.shadow": "#00000040",
        "selection.background": hex_with_alpha(prim_container, "aa"),
        "descriptionForeground": on_surf_var,
        "errorForeground": error,

        # Window & Title Bar
        "titleBar.activeBackground": bg,
        "titleBar.activeForeground": on_surface,
        "titleBar.inactiveBackground": bg,
        "titleBar.inactiveForeground": hex_with_alpha(on_surf_var, "99"),
        "titleBar.border": hex_with_alpha(outline_var, "40"),

        # Activity Bar
        "activityBar.background": surf_low,
        "activityBar.foreground": primary,
        "activityBar.inactiveForeground": hex_with_alpha(on_surf_var, "99"),
        "activityBar.border": hex_with_alpha(outline_var, "40"),
        "activityBarBadge.background": primary,
        "activityBarBadge.foreground": on_primary,
        "activityBar.activeBorder": primary,

        # Side Bar
        "sideBar.background": surf_low,
        "sideBar.foreground": on_surface,
        "sideBar.border": hex_with_alpha(outline_var, "40"),
        "sideBarTitle.foreground": primary,
        "sideBarSectionHeader.background": surf_mid,
        "sideBarSectionHeader.foreground": on_surface,
        "sideBarSectionHeader.border": hex_with_alpha(outline_var, "30"),

        # Editor
        "editor.background": bg,
        "editor.foreground": on_surface,
        "editorLineNumber.foreground": hex_with_alpha(outline, "88"),
        "editorLineNumber.activeForeground": primary,
        "editorCursor.foreground": primary,
        "editor.selectionBackground": hex_with_alpha(prim_container, "70"),
        "editor.inactiveSelectionBackground": hex_with_alpha(prim_container, "35"),
        "editor.selectionHighlightBackground": hex_with_alpha(prim_container, "40"),
        "editor.wordHighlightBackground": hex_with_alpha(secondary, "30"),
        "editor.wordHighlightStrongBackground": hex_with_alpha(primary, "40"),
        "editor.findMatchBackground": hex_with_alpha(tertiary, "60"),
        "editor.findMatchHighlightBackground": hex_with_alpha(tertiary, "30"),
        "editor.lineHighlightBackground": hex_with_alpha(surf_mid, "60"),
        "editor.lineHighlightBorder": "#00000000",
        "editorBracketMatch.background": hex_with_alpha(primary, "30"),
        "editorBracketMatch.border": primary,
        "editorWhitespace.foreground": hex_with_alpha(outline_var, "50"),
        "editorIndentGuide.background1": hex_with_alpha(outline_var, "30"),
        "editorIndentGuide.activeBackground1": hex_with_alpha(primary, "60"),

        # Tabs
        "editorGroupHeader.tabsBackground": surf_low,
        "editorGroupHeader.tabsBorder": hex_with_alpha(outline_var, "40"),
        "tab.activeBackground": bg,
        "tab.activeForeground": primary,
        "tab.inactiveBackground": surf_low,
        "tab.inactiveForeground": on_surf_var,
        "tab.border": hex_with_alpha(outline_var, "30"),
        "tab.activeBorderTop": primary,
        "tab.hoverBackground": surf_mid,
        "tab.hoverForeground": on_surface,

        # Status Bar
        "statusBar.background": surf_mid,
        "statusBar.foreground": on_surface,
        "statusBar.border": hex_with_alpha(outline_var, "40"),
        "statusBar.noFolderBackground": surf_mid,
        "statusBar.debuggingBackground": prim_container,
        "statusBar.debuggingForeground": on_prim_container,
        "statusBarItem.remoteBackground": primary,
        "statusBarItem.remoteForeground": on_primary,
        "statusBarItem.hoverBackground": hex_with_alpha(surf_high, "80"),
        "statusBarItem.prominentBackground": sec_container,
        "statusBarItem.prominentForeground": on_surface,

        # Panels & Terminal
        "panel.background": surf_low,
        "panel.border": hex_with_alpha(outline_var, "40"),
        "panelTitle.activeForeground": primary,
        "panelTitle.activeBorder": primary,
        "panelTitle.inactiveForeground": on_surf_var,
        "terminal.background": bg,
        "terminal.foreground": on_surface,
        "terminalCursor.foreground": primary,

        # Lists & Trees
        "list.activeSelectionBackground": hex_with_alpha(prim_container, "cc"),
        "list.activeSelectionForeground": on_prim_container,
        "list.inactiveSelectionBackground": hex_with_alpha(surf_high, "cc"),
        "list.inactiveSelectionForeground": on_surface,
        "list.hoverBackground": hex_with_alpha(surf_mid, "99"),
        "list.hoverForeground": on_surface,
        "list.focusBackground": hex_with_alpha(surf_high, "bb"),
        "list.highlightForeground": primary,

        # Inputs & Dropdowns
        "input.background": surf_highest,
        "input.foreground": on_surface,
        "input.border": outline_var,
        "input.placeholderForeground": hex_with_alpha(on_surf_var, "99"),
        "inputOption.activeBorder": primary,
        "dropdown.background": surf_high,
        "dropdown.foreground": on_surface,
        "dropdown.border": outline_var,

        # Buttons
        "button.background": primary,
        "button.foreground": on_primary,
        "button.hoverBackground": hex_with_alpha(primary, "dd"),
        "button.secondaryBackground": surf_high,
        "button.secondaryForeground": on_surface,
        "button.secondaryHoverBackground": surf_highest,

        # Menus & Badges
        "menu.background": surf_high,
        "menu.foreground": on_surface,
        "menu.selectionBackground": prim_container,
        "menu.selectionForeground": on_prim_container,
        "menu.separatorBackground": hex_with_alpha(outline_var, "50"),
        "badge.background": primary,
        "badge.foreground": on_primary,
        "progressBar.background": primary,

        # Breadcrumbs
        "breadcrumb.background": bg,
        "breadcrumb.foreground": on_surf_var,
        "breadcrumb.focusForeground": on_surface,
        "breadcrumb.activeSelectionForeground": primary,

        # Scrollbars
        "scrollbarSlider.background": hex_with_alpha(outline_var, "40"),
        "scrollbarSlider.hoverBackground": hex_with_alpha(outline_var, "80"),
        "scrollbarSlider.activeBackground": hex_with_alpha(outline, "aa"),

        # Git decoration
        "gitDecoration.addedResourceForeground": green,
        "gitDecoration.modifiedResourceForeground": yellow,
        "gitDecoration.deletedResourceForeground": error,
        "gitDecoration.untrackedResourceForeground": teal,
        "gitDecoration.ignoredResourceForeground": hex_with_alpha(outline, "70"),

        # Chat & Interactive AI Agent Panel (Antigravity Chat)
        "chat.foreground": on_surface,
        "chat.requestForeground": on_surface,
        "chat.requestBackground": surf_mid,
        "chat.requestBorder": hex_with_alpha(outline_var, "50"),
        "chat.requestBubbleBackground": surf_mid,
        "chat.requestBubbleForeground": on_surface,
        "chat.requestBubbleHoverBackground": surf_high,
        "chat.responseBackground": bg,
        "chat.responseForeground": on_surface,
        "chat.responseBubbleBackground": surf_mid,
        "chat.responseBubbleForeground": on_surface,
        "chat.requestCodeBorder": hex_with_alpha(outline_var, "60"),
        "chat.avatarBackground": primary,
        "chat.avatarForeground": on_primary,
        "chat.agentForeground": primary,
        "chat.agentBackground": surf_high,
        "chat.slashCommandBackground": prim_container,
        "chat.slashCommandForeground": on_prim_container,
        "chat.checkpointSeparator": hex_with_alpha(outline_var, "60"),
        "chat.linesAddedForeground": green,
        "chat.linesRemovedForeground": error,
        "chat.editedFileForeground": secondary,
        "interactive.activeCodeBorder": primary,
        "interactive.inactiveCodeBorder": hex_with_alpha(outline_var, "50"),
        "editorWidget.background": surf_mid,
        "editorWidget.foreground": on_surface,
        "editorWidget.border": hex_with_alpha(outline_var, "60"),
        "widget.border": hex_with_alpha(outline_var, "60"),

        # Markdown & Chat Text (File names, paths, inline commands, and code blocks)
        "textLink.foreground": primary,
        "textLink.activeForeground": secondary,
        "textPreformat.foreground": tertiary,
        "textPreformat.background": hex_with_alpha(surf_highest, "ee"),
        "textCodeBlock.background": surf_mid,
        "textBlockQuote.background": surf_mid,
        "textBlockQuote.border": primary,
        "textSeparator.foreground": hex_with_alpha(outline_var, "60"),

        # Command Center, Toolbars & Keybindings
        "commandCenter.inactiveBorder": hex_with_alpha(outline_var, "40"),
        "commandCenter.border": hex_with_alpha(outline_var, "60"),
        "commandCenter.background": surf_mid,
        "commandCenter.foreground": on_surface,
        "commandCenter.activeForeground": primary,
        "commandCenter.activeBackground": surf_high,
        "toolbar.hoverBackground": hex_with_alpha(surf_high, "80"),
        "keybindingLabel.background": surf_high,
        "keybindingLabel.foreground": on_surface,
        "keybindingLabel.border": hex_with_alpha(outline_var, "60"),
        "keybindingLabel.bottomBorder": outline_var,

        # Symbol Icons (File / Folder chips in chat)
        "symbolIcon.fileForeground": secondary,
        "symbolIcon.folderForeground": primary,

        # Diff Editor (File changes & diffs in chat)
        "diffEditor.insertedLineBackground": hex_with_alpha(green, "20"),
        "diffEditor.insertedTextBackground": hex_with_alpha(green, "35"),
        "diffEditor.removedLineBackground": hex_with_alpha(error, "20"),
        "diffEditor.removedTextBackground": hex_with_alpha(error, "35"),

    }

    # Syntax tokens
    syntax = {
        "textMateRules": [
            {
                "scope": ["comment", "punctuation.definition.comment"],
                "settings": {"foreground": hex_with_alpha(on_surf_var, "bb"), "fontStyle": "italic"},
            },
            {
                "scope": ["keyword", "storage.type", "storage.modifier", "keyword.control"],
                "settings": {"foreground": primary, "fontStyle": "bold"},
            },
            {
                "scope": ["entity.name.function", "support.function", "meta.function-call"],
                "settings": {"foreground": secondary},
            },
            {
                "scope": ["string", "punctuation.definition.string"],
                "settings": {"foreground": green},
            },
            {
                "scope": ["constant.numeric", "constant.language", "constant.character"],
                "settings": {"foreground": peach},
            },
            {
                "scope": ["entity.name.type", "entity.name.class", "support.class", "support.type"],
                "settings": {"foreground": tertiary, "fontStyle": "bold"},
            },
            {
                "scope": ["variable", "variable.parameter", "meta.definition.variable"],
                "settings": {"foreground": on_surface},
            },
            {
                "scope": ["entity.name.tag", "punctuation.definition.tag"],
                "settings": {"foreground": primary},
            },
            {
                "scope": ["entity.other.attribute-name"],
                "settings": {"foreground": secondary, "fontStyle": "italic"},
            },
            {
                "scope": ["keyword.operator", "punctuation.separator", "punctuation.terminator"],
                "settings": {"foreground": on_surf_var},
            },
        ]
    }

    return workbench, syntax


def create_theme_extension(workbench: dict, syntax: dict, mode: str):
    EXT_DIR.mkdir(parents=True, exist_ok=True)
    themes_dir = EXT_DIR / "themes"
    themes_dir.mkdir(parents=True, exist_ok=True)

    pkg = {
        "name": "caelestia-theme",
        "displayName": "Caelestia Dynamic Theme",
        "description": "Dynamic Material You theme synchronized with Caelestia Desktop Environment",
        "version": "1.0.0",
        "publisher": "caelestia",
        "engines": {"vscode": "^1.60.0"},
        "categories": ["Themes"],
        "contributes": {
            "themes": [
                {
                    "label": "Caelestia",
                    "uiTheme": "vs-dark" if mode == "dark" else "vs",
                    "path": "./themes/caelestia.json",
                }
            ]
        },
    }
    (EXT_DIR / "package.json").write_text(json.dumps(pkg, indent=2))

    theme_content = {
        "name": "Caelestia",
        "type": mode,
        "colors": workbench,
        "tokenColors": syntax["textMateRules"],
    }
    THEME_JSON.write_text(json.dumps(theme_content, indent=2))

    # Link to VSCodium extensions if it exists
    if VSCODIUM_EXT_DIR.parent.exists() and not VSCODIUM_EXT_DIR.exists():
        try:
            VSCODIUM_EXT_DIR.symlink_to(EXT_DIR, target_is_directory=True)
        except Exception:
            pass


def update_settings(workbench: dict, syntax: dict, mode: str):
    targets = [ANTIGRAVITY_SETTINGS, VSCODIUM_SETTINGS]
    for target in targets:
        if not target.parent.exists():
            target.parent.mkdir(parents=True, exist_ok=True)

        settings = {}
        if target.exists():
            try:
                settings = json.loads(target.read_text())
            except Exception:
                settings = {}

        settings["workbench.colorTheme"] = "Caelestia"
        settings["workbench.colorCustomizations"] = workbench
        settings["editor.tokenColorCustomizations"] = syntax

        target.write_text(json.dumps(settings, indent=4) + "\n")


def main():
    if not SCHEME_FILE.exists():
        print(f"Caelestia scheme file not found at {SCHEME_FILE}", file=sys.stderr)
        return 1

    try:
        scheme_data = json.loads(SCHEME_FILE.read_text())
    except Exception as e:
        print(f"Failed to read scheme.json: {e}", file=sys.stderr)
        return 1

    colors = scheme_data.get("colours", {})
    mode = scheme_data.get("mode", "dark")

    workbench, syntax = build_theme_tokens(colors, mode)

    create_theme_extension(workbench, syntax, mode)
    update_settings(workbench, syntax, mode)

    print(f"✓ Synchronized Caelestia dynamic theme to Antigravity IDE (mode: {mode})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
