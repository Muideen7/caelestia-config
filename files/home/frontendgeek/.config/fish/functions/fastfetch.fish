function fastfetch --description 'Run fastfetch with a random image from ~/.config/fastfetch/images'
    set -l img_dir "$HOME/.config/fastfetch/images"
    set -l images (find "$img_dir" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) 2>/dev/null)

    if test (count $images) -gt 0
        set -l random_img (printf "%s\n" $images | shuf -n 1)

        set -l logo_type "sixel"
        if test -n "$KITTY_WINDOW_ID"; or test "$TERM" = "xterm-kitty"; or test -n "$GHOSTTY_RESOURCES_DIR"; or test -n "$WEZTERM_PANE"
            set logo_type "kitty"
        end

        command fastfetch --logo "$random_img" --logo-type $logo_type --logo-height 13 $argv
    else
        command fastfetch $argv
    end
end
