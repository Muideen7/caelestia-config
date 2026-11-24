function fish_greeting
    # Ensure Caelestia dynamic color sequences are applied
    cat ~/.local/state/caelestia/sequences.txt 2> /dev/null

    # Fastfetch renders CachyOS ASCII logo on the left, and Caelestia banner + system info table on the right
    if test -n "$LINES"; and test $LINES -ge 38
        fastfetch --logo cachyos --logo-color-1 "38;5;16" --logo-color-2 "38;5;17" --logo-padding-top 0
    else
        fastfetch
    end
end
