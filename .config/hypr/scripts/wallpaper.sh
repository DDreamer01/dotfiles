#!/usr/bin/env bash
# ─── Wallpaper Setter & Cycler (swww / hyprpaper) ───────────────
# Usage:
#   wallpaper.sh                -> default crimson wallpaper
#   wallpaper.sh /path/to/img   -> specific wallpaper
#   wallpaper.sh cycle          -> next wallpaper in directory (Super + W)

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
DEFAULT_WALLPAPER="$WALLPAPER_DIR/crimson_default.png"
STATE="$HOME/.cache/wallpaper_index"

if [ "$1" = "cycle" ]; then
    mapfile -t WP < <(find "$WALLPAPER_DIR" -maxdepth 1 \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | sort)
    [ ${#WP[@]} -eq 0 ] && echo "No wallpapers found in $WALLPAPER_DIR" && exit 1
    CUR=0
    [ -f "$STATE" ] && read -r CUR < "$STATE" 2>/dev/null
    CUR=$(( (CUR + 1) % ${#WP[@]} ))
    echo "$CUR" > "$STATE"
    TARGET="${WP[$CUR]}"
    notify-send -a "Wallpaper" "$(basename "$TARGET")" -i "$TARGET" -t 2500 2>/dev/null
else
    TARGET="${1:-$DEFAULT_WALLPAPER}"
fi

[ ! -f "$TARGET" ] && echo "Wallpaper file $TARGET not found." && exit 1

if command -v swww >/dev/null 2>&1; then
    if ! pgrep -x "swww-daemon" > /dev/null; then
        swww-daemon &
        sleep 0.5
    fi
    swww img "$TARGET" \
        --transition-type wipe \
        --transition-duration 1.2 \
        --transition-fps 60 \
        --transition-angle 30
elif command -v hyprpaper >/dev/null 2>&1; then
    CONF="$HOME/.config/hypr/hyprpaper.conf"
    cat > "$CONF" << CONFEOF
ipc = on
preload = $TARGET
splash = false
wallpaper {
    monitor = eDP-1
    path = $TARGET
    fit_mode = cover
}
wallpaper {
    monitor =
    path = $TARGET
    fit_mode = cover
}
CONFEOF

    if ! pgrep -x "hyprpaper" > /dev/null; then
        hyprpaper -c "$CONF" &
    else
        # hyprpaper 0.8+ dropped the "preload" IPC request:
        # "wallpaper" auto-loads; [mon],[path],[fit_mode] with fit mode optional
        hyprctl hyprpaper wallpaper ",$TARGET" 2>/dev/null || true
    fi
fi
