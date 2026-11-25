-- Personal Hyprland config (managed by the user).
-- This file is loaded by the dots after the built-in config and is NOT touched
-- by updates, so keep personal keybinds and autostarts here.

-- Make KDE/Kirigami apps (System Monitor, KDEConnect, ...) use the KDE QQC2
-- desktop style, which reads the Caelestia-coloured ~/.config/kdeglobals.
-- (That file is regenerated on every wallpaper change by kde-scheme.py,
-- hooked into caelestia's theme.postHook.)
hl.env("QT_QUICK_CONTROLS_STYLE", "org.kde.desktop")

-- Optimize layer surface rendering under load (eliminate compositor double-animation and edge-blur churn)
hl.layer_rule({ match = { namespace = "caelestia-drawers" }, no_anim = true, ignore_alpha = 0.45 })

-- Walker: global search (apps + files + clipboard + symbols + calc)
hl.layer_rule({ match = { namespace = "walker" }, animation = "popin 80%%" })
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("walker"))
-- SUPER + D is the communication workspace (see cli.json "toggles"), so the
-- files-only walker lives on SUPER + SHIFT + D.
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("walker -m files"))

-- Clipboard picker (SUPER + V): same fuzzel/cliphist list as the stock dots,
-- but with a "Clear all clipboard history" row at the top. The stock bind is
-- disabled via `kbClipboard = ""` in hypr-vars.lua.
hl.bind(
    "SUPER + V",
    hl.dsp.exec_cmd("pkill fuzzel || " .. os.getenv("HOME") .. "/.local/bin/caelestia-clipboard.sh")
)

-- HyprMod managed settings
pcall(require, "hyprland-gui")

-- Keep a shared history for normal and special workspaces (Alt + Tab switching).
local current_workspace
local previous_workspace
local switching_workspace = false

local function remember_workspace(name)
    if not switching_workspace and name and name ~= "" and name ~= current_workspace then
        previous_workspace = current_workspace
        current_workspace = name
    end
end

local function active_workspace_name()
    local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()
    return workspace and workspace.name
end

remember_workspace(active_workspace_name())
hl.on("workspace.active", function(workspace)
    if workspace and workspace.name then
        remember_workspace(workspace.name)
    end
end)
hl.on("workspace.special_active", function(workspace)
    if workspace and workspace.name then
        remember_workspace(workspace.name)
    else
        local normal = hl.get_active_workspace()
        remember_workspace(normal and normal.name)
    end
end)

hl.config({ binds = { allow_workspace_cycles = true } })
hl.bind("ALT + TAB", function()
    local target = previous_workspace
    if not target then
        hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
        return
    end
    local origin = active_workspace_name()
    switching_workspace = true
    local special = hl.get_active_special_workspace()
    if special and not target:match("^special:") then
        hl.dispatch(hl.dsp.workspace.toggle_special((special.name:gsub("^special:", ""))))
    end
    hl.dispatch(hl.dsp.focus({ workspace = target }))
    switching_workspace = false
    current_workspace = active_workspace_name()
    if current_workspace == target then
        previous_workspace = origin
    end
end, { description = "Toggle previous workspace" })


-- Reset any lingering SDDM fingerprint session on session start
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl stop fprintd 2>/dev/null || true")
end)

-- Prevent bright white flash during SDDM -> Hyprland handoff before Quickshell renders
hl.config({
    misc = {
        background_color = "rgb(0d0f14)",
    },
})
