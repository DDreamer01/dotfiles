#!/usr/bin/env bash
# ─── SwayNC control-center Bluetooth label sync ─────────────────────────────
# Polls real bluetooth state; when it changes, rewrites the Bluetooth button
# label in swaync's config and reloads the UI.
#   󰂳 connected (+ device), 󰂯 powered on, 󰂲 off

CFG="$HOME/.config/swaync/config.json"

sync_label() {
    local connected_devices power
    connected_devices=$(bluetoothctl devices Connected 2>/dev/null | wc -l)
    power=$(bluetoothctl show 2>/dev/null | grep -m1 "Powered:")
    local glyph label
    if [[ $power == *yes* ]]; then
        (( connected_devices > 0 )) && glyph='󰂳' && label="󰂳 Bluetooth"
        (( connected_devices == 0 )) && glyph='󰂯' && label="󰂯 Bluetooth"
    else
        glyph='󰂲'
        label="󰂲 Bluetooth"
    fi

    CUR=$(jq -r '.["widget-config"]["buttons-grid"].actions[] |
                 select(.command != null) |
                 select(.command | test("btmenu.sh")) | .label' "$CFG")
    if [[ "$CUR" != "$label" ]]; then
        python3 - "$CFG" "$label" <<'PY'
import json, sys
path, label = sys.argv[1], sys.argv[2]
cfg = json.load(open(path))
for a in cfg["widget-config"]["buttons-grid"]["actions"]:
    cmd = a.get("command", "")
    if "btmenu.sh" in cmd:
        a["label"] = label
json.dump(cfg, open(path, "w"), indent=2)
PY
        swaync-client -R >/dev/null 2>&1
        swaync-client -rs >/dev/null 2>&1
        echo "$(date '+%r') label -> $label"
    fi
}

while true; do
    sync_label
    sleep 5
done
