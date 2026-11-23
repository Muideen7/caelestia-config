#!/usr/bin/env bash
#
# Caelestia clipboard picker + "Clear all" action.
#
# A drop-in replacement for `caelestia clipboard` (same cliphist store, same
# fuzzel look) that adds a wipe-everything entry at the top of the list.
#
#   Enter on a normal row  -> copy that entry back to the clipboard
#   Enter on "Clear all"   -> asks for confirmation, then wipes history
#
# Wired up as SUPER + V in ~/.config/caelestia/hypr-user.lua (the stock bind is
# disabled in ~/.config/caelestia/hypr-vars.lua).
set -u

CLEAR_LABEL='>> Clear all clipboard history'
CONFIRM_LABEL='Yes, clear all clipboard history'

# cliphist previews can contain stray NUL bytes; strip them (decode matches by id).
history="$(cliphist list 2>/dev/null | tr -d '\0' || true)"

if [ -z "$history" ]; then
    printf 'Clipboard history is empty\n' |
        fuzzel --dmenu --placeholder='Nothing stored yet' >/dev/null 2>&1 || true
    exit 0
fi

choice="$(
    { printf '%s\n' "$CLEAR_LABEL"; printf '%s\n' "$history"; } |
        fuzzel --dmenu --placeholder='Type to search — pick "Clear all clipboard history" to wipe'
)" || exit 0

[ -z "$choice" ] && exit 0

if [ "$choice" = "$CLEAR_LABEL" ]; then
    confirm="$(
        printf '%s\n%s\n' 'Cancel' "$CONFIRM_LABEL" |
            fuzzel --dmenu --placeholder='Wipe the entire clipboard history?'
    )" || exit 0

    if [ "$confirm" = "$CONFIRM_LABEL" ]; then
        cliphist wipe
    fi
    exit 0
fi

printf '%s\n' "$choice" | cliphist decode 2>/dev/null | wl-copy 2>/dev/null
