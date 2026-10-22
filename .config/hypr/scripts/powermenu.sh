#!/bin/bash
# ─── System / Power Menu (Last Horizon Style) ─────────────────────────

LOCK="󰌾  Lock"
SUSPEND="󰤄  Suspend"
RELAUNCH="󰑐  Relaunch"
RESTART="󰜉  Restart"
SHUTDOWN="󰐥  Shutdown"

CHOSEN=$(printf "%s\n%s\n%s\n%s\n%s" "$LOCK" "$SUSPEND" "$RELAUNCH" "$RESTART" "$SHUTDOWN" | rofi -dmenu -i -click-to-exit -theme ~/.config/rofi/powermenu.rasi -p "System...")

case "$CHOSEN" in
    "$LOCK")
        hyprlock
        ;;
    "$SUSPEND")
        hyprlock &
        sleep 0.5
        systemctl suspend
        ;;
    "$RELAUNCH")
        hyprctl reload && systemctl --user restart waybar && swaync-client -R && swaync-client -rs
        ;;
    "$RESTART")
        systemctl reboot
        ;;
    "$SHUTDOWN")
        systemctl poweroff
        ;;
esac
