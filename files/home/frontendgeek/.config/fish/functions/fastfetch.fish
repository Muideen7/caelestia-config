function fastfetch --description 'Run fastfetch with a random image from ~/.config/fastfetch/images'
    set -l img_dir "$HOME/.config/fastfetch/images"
    set -l images (find "$img_dir" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) 2>/dev/null)

    if test (count $images) -gt 0
        set -l random_img (printf "%s\n" $images | shuf -n 1)
        command fastfetch --logo "$random_img" $argv
    else
        command fastfetch $argv
    end
end
