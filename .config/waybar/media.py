#!/usr/bin/env python3
"""Waybar media widget (MPRIS, prefers Spotify). Outputs Waybar JSON.
Icon-only: state glyph in the bar, song/artist on hover, click = play/pause."""
import json
import subprocess

PLAYERS = "spotify,firefox,totem,%any%"
ICON = {"Playing": "󰐊", "Paused": "󰏤", "Stopped": "󰓇"}

try:
    raw = subprocess.run(
        ["playerctl", "-p", PLAYERS, "metadata", "-f",
         "{{status}}|{{title}}|{{artist}}"],
        capture_output=True, text=True, timeout=3,
    ).stdout.strip()
except Exception:
    raw = ""

if not raw:
    print(json.dumps({"text": "", "class": "idle"}))
else:
    try:
        status, title, artist = raw.split("|", 2)
    except ValueError:
        status, title, artist = "", raw, ""
    print(json.dumps({
        "text": ICON.get(status, "󰓛"),
        "class": status.lower(),
        "tooltip": (title + (f" · {artist}" if artist else "")) or status,
    }))
