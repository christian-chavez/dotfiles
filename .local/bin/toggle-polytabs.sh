#!/bin/sh
# =============================================================================
# toggle-polytabs.sh -- master on/off switch for the pdftabs bar
# =============================================================================
# Flips the flag that watch-polytabs.sh reads, then triggers one immediate
# reconcile so the bar reacts now instead of on the next desktop change.
# Bind this to a key in sxhkd.
# =============================================================================
set -eu

RUN_DIR='/tmp'
ENABLED_FILE="$RUN_DIR/pdftabs.enabled"
HERE=$(dirname "$0")

if [ "$(cat "$ENABLED_FILE" 2>/dev/null || echo 1)" = 1 ]; then
    echo 0 > "$ENABLED_FILE"
    msg='pdftabs off'
else
    echo 1 > "$ENABLED_FILE"
    msg='pdftabs on'
fi

command -v notify-send >/dev/null 2>&1 && notify-send -t 1200 "$msg" || true

exec "$HERE/watch-polytabs.sh" --once
