#!/bin/sh
# Mouse tuning for: Telink Wireless Receiver Mouse (xinput id may change)

NAME='Telink Wireless Receiver Mouse'

ID="$(xinput list --id-only "$NAME" 2>/dev/null)"

# If not found, exit silently (prevents errors during login)
[ -z "$ID" ] && exit 0

# Flat (no accel) + neutral accel speed
xinput set-prop "$ID" 'libinput Accel Profile Enabled' 1, 0
xinput set-prop "$ID" 'libinput Accel Speed' 0

# Pointer scaling (adjust 1.10 to your taste)
xinput set-prop "$ID" 'Coordinate Transformation Matrix' \
1.08 0 0 \
0 1.08 0 \
0 0 1

