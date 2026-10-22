#!/bin/bash
# ─── Keybindings & Cheatsheet (Omarchy Style) ─────────────────────────

python3 -c "
items = [
    ('SUPER + K', 'Keybindings'),
    ('SUPER + /', 'Keybindings (alias)'),
    ('SUPER + SPACE', 'Menu'),
    ('SUPER + RETURN', 'Terminal'),
    ('SUPER + B', 'Browser'),
    ('SUPER + E', 'File manager'),
    ('SUPER + Q', 'Close window'),
    ('SUPER + F', 'Fullscreen'),
    ('SUPER + V', 'Floating'),
    ('SUPER + T', 'Split layout'),
    ('SUPER + N', 'Notification center'),
    ('SUPER + ESCAPE', 'Power menu'),
    ('SUPER SHIFT + V', 'Clipboard history'),
    ('SUPER + H / J / L', 'Focus window (left/down/right)'),
    ('SUPER SHIFT + H / J / K / L', 'Move window (left/down/up/right)'),
    ('SUPER ALT + H / J / K / L', 'Resize window'),
    ('SUPER + 1..5', 'Switch workspace'),
    ('SUPER SHIFT + 1..5', 'Move window to workspace'),
    ('SUPER + TAB', 'Previous workspace'),
    ('SUPER + SCROLL', 'Cycle workspaces'),
    ('SUPER + W', 'Next wallpaper'),
    ('PRINT', 'Screenshot area'),
    ('SUPER + PRINT', 'Screenshot full screen'),
    ('SUPER SHIFT + PRINT', 'Screenshot active window')
]
max_len = 30
for k, v in items:
    print(k + '\u00a0' * (max_len - len(k)) + '→ ' + v)
" | rofi -dmenu -i -click-to-exit -theme ~/.config/rofi/keybinds.rasi -p "Keybindings..."
