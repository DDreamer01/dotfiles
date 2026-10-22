#!/usr/bin/env python3
"""Waybar bluetooth module status. Outputs Waybar JSON (icon by rfkill/connect state)."""
import json
import subprocess


def run(*args):
    try:
        return subprocess.run(args, capture_output=True, text=True, timeout=3).stdout
    except Exception:
        return ""


show = run("bluetoothctl", "show")
powered = "Powered: yes" in show

if not powered:
    print(json.dumps({
        "text": "󰂲",
        "class": "off",
        "tooltip": "Bluetooth off\n(click to open menu)",
    }))
else:
    connected = [
        ln.split(" ", 2)[-1]
        for ln in run("bluetoothctl", "devices", "Connected").strip().splitlines()
        if ln.startswith("Device ")
    ]
    names = [d.strip() or "device" for d in connected]
    text = "󰂱" if not names else "󰂱"
    class_ = "connected" if names else "disconnected"
    tooltip = ("\n".join(names) + "\n" if names else "No devices connected\n") + "(click to open menu)"
    print(json.dumps({"text": text, "class": class_, "tooltip": tooltip}))
