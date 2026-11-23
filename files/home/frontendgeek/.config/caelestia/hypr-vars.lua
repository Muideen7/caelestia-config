-- Personal Hyprland variable overrides (managed by the user).
-- This file is loaded by the dots and is NOT touched by updates.

return {
    browser = "brave",

    -- Clipboard: the stock SUPER + V bind is intentionally disabled here and
    -- re-created in ~/.config/caelestia/hypr-user.lua, where it opens a picker
    -- that also offers "Clear all clipboard history". An empty string tells the
    -- dots' keybind builder not to register the built-in bind.
    kbClipboard = "",

    -- Window cycling with Super (Windows) + Tab
    kbWindowCycleNext = "",
    kbWindowCyclePrev = "",
}
