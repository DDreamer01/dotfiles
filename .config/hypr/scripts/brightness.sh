#!/usr/bin/env bash
# ─── Brightness setter with a safety floor ──────────────────────────────────
# Usage: brightness.sh +5% | -5% | 40%
# Floor: MIN_PCT of max (default 5) so 0% (black screen) is unreachable.

MIN_PCT=5
MAX=$(brightnessctl -d intel_backlight m) ; (( MAX == 0 )) && exit 1
MIN=$((MAX * MIN_PCT / 100)) ; (( MIN < 1 )) && MIN=1
CUR=$(brightnessctl -d intel_backlight g)
CUR_PCT=$((CUR * 100 / MAX))

NUM=${1//[%+-]}   # pattern with '-' LAST = literal dash (no range error)
case "$1" in
    +*) NEW=$((CUR_PCT + NUM)) ;;
    -*) NEW=$((CUR_PCT - NUM)) ;;
    ''|none) NEW=$CUR_PCT ;;
    *) NEW=$NUM ;;
esac

(( NEW < MIN_PCT )) && NEW=$MIN_PCT
(( NEW > 100 )) && NEW=100

brightnessctl -d intel_backlight s "$NEW%"
