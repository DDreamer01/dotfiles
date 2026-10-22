#!/usr/bin/env bash
# --- Bluetooth quick menu (Rofi, Last Horizon style) ---------------------------
# Icon-accurate state: OFF is respected even when the controller is rfkill-wedged.

BT_ON() {
    local out
    out=$(bluetoothctl show 2>/dev/null | grep -m1 "Powered:")
    [[ $out == *yes* ]]
}

# map a device name back to its MAC
mac_for_name() {
    bluetoothctl devices 2>/dev/null | while read -r _ mac name; do
        [[ "$1" == *"$name"* ]] && echo "$mac" && break
    done | head -1
}

menu() {
    local entries=()
    if ! BT_ON; then
        entries+=('󰂯  Turn Bluetooth on')
    else
        while read -r _ mac name; do
            [[ -z $name ]] && continue
            local con
            con=$(bluetoothctl info "$mac" 2>/dev/null | grep -m1 "Connected:")
            entries+=("$([[ $con == *yes* ]] && echo '󰂱  ' || echo '󰂯  ')${name}")
        done < <(bluetoothctl devices Paired 2>/dev/null)
        entries+=('󰐍  Scan for new devices')
        entries+=('󰂲  Turn Bluetooth off')
    fi
    printf '%s\n' "${entries[@]}" | rofi -dmenu -i -theme ~/.config/rofi/lasthorizon.rasi -p 'Bluetooth...'
}

SELECTION=$(menu)
[[ -z $SELECTION ]] && exit 0

case "$SELECTION" in
    *"Turn Bluetooth on"*)
        rfkill unblock bluetooth >/dev/null 2>&1
        sleep 2.5   # bluetoothd needs ~2.5s to claim the rfkill-freed adapter
        bluetoothctl power on >/dev/null 2>&1
        ;;
    *"Turn Bluetooth off"*)
        rfkill block bluetooth >/dev/null 2>&1
        ;;
    *"Scan for new devices"*)
        notify-send -a "Bluetooth" "Scanning 7s..." -t 3000 2>/dev/null
        bluetoothctl scan on >/dev/null 2>&1 &
        scanpid=$!
        sleep 7
        kill "$scanpid" 2>/dev/null
        bluetoothctl scan off >/dev/null 2>&1
        # unpaired, named devices
        UNPAIRED=$(bluetoothctl devices 2>/dev/null | while read -r _ mac name; do
            [[ -z $name ]] && continue
            bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes" && continue
            echo "󰐍  $name"
        done)
        [[ -z $UNPAIRED ]] && { notify-send -a "Bluetooth" "No unpaired devices found" -t 2500 2>/dev/null; exit 0; }
        CHOSEN=$(printf '%s\n' "$UNPAIRED" | rofi -dmenu -i -theme ~/.config/rofi/lasthorizon.rasi -p 'Pair...')
        [[ -z $CHOSEN ]] && exit 0
        # (icon prefix tolerated by mac_for_name's substring match)
        mac=$(mac_for_name "$CHOSEN")
        [[ -z $mac ]] && exit 0
        notify-send -a "Bluetooth" "Pairing ${CHOSEN#headphones}..." -t 2500 2>/dev/null
        bluetoothctl pair "$mac" >/dev/null 2>&1
        bluetoothctl trust "$mac" >/dev/null 2>&1
        bluetoothctl connect "$mac" >/dev/null 2>&1
        if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
            notify-send -a "Bluetooth" "Paired & connected ✔" -t 2000 2>/dev/null
        else
            notify-send -a "Bluetooth" "Paired (connect later)" -t 2500 2>/dev/null
        fi
        ;;
    *)  # device row → toggle connect/disconnect
        mac=$(mac_for_name "$SELECTION")
        [[ -z $mac ]] && exit 0
        if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
            bluetoothctl disconnect "$mac" >/dev/null 2>&1
            notify-send -a "Bluetooth" "Disconnected ✔" -t 2000 2>/dev/null
        else
            notify-send -a "Bluetooth" "Connecting..." -t 1500 2>/dev/null
            bluetoothctl connect "$mac" >/dev/null 2>&1
            if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
                notify-send -a "Bluetooth" "Connected ✔" -t 2000 2>/dev/null
            else
                notify-send -a "Bluetooth" "Connection failed ✖" -t 2500 -u critical 2>/dev/null
            fi
        fi
        ;;
esac
