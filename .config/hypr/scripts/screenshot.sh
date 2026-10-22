#!/usr/bin/env bash
# ─── Screenshot Utility Script (Grim + Slurp + wl-copy) ─────────
# Usage:
#   screenshot.sh area   -> Area selection to clipboard & file
#   screenshot.sh full   -> Full screen to clipboard & file
#   screenshot.sh active -> Active window to clipboard & file

DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$DIR"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
FILE="$DIR/screenshot_${TIMESTAMP}.png"

case "$1" in
    area)
        GEOM=$(slurp -b '#0c0b0c88' -c '#c38b7b' -w 2)
        [ -z "$GEOM" ] && exit 0
        grim -g "$GEOM" "$FILE"
        ;;
    full)
        grim "$FILE"
        ;;
    active)
        GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        [ -z "$GEOM" ] && exit 0
        grim -g "$GEOM" "$FILE"
        ;;
    *)
        GEOM=$(slurp -b '#0c0b0c88' -c '#c38b7b' -w 2)
        [ -z "$GEOM" ] && exit 0
        grim -g "$GEOM" "$FILE"
        ;;
esac

if [ -f "$FILE" ]; then
    wl-copy < "$FILE"
    notify-send -a "Screenshot" "Captured & Copied" "Saved to $(basename "$FILE")" -i "$FILE"
fi
