#!/usr/bin/env bash

HDMI='HDMI-A-0'
EDP='eDP'

hdmi_active() {
    xrandr --listactivemonitors | rg -q "\\b${HDMI}\$"
}

edp_active() {
    xrandr --listactivemonitors | rg -q "\\b${EDP}\$"
}

if hdmi_active; then
    if edp_active; then
        # Dual-monitor setup
        if xrandr --verbose | rg -q 'HP E202'; then
            xrandr \
                --output "$EDP" --primary --mode 1366x768 --rotate normal \
                --output "$HDMI" --mode 1600x900 --rate 60 --rotate normal --left-of "$EDP"
        else
            xrandr \
                --output "$EDP" --primary --mode 1366x768 --rotate normal \
                --output "$HDMI" --auto --rotate normal --left-of "$EDP"
        fi

        bspc wm -O "$HDMI" "$EDP"
        bspc monitor "$EDP"  -d 6 7 8 9 10
        bspc monitor "$HDMI" -d 1 2 3 4 5
    else
        # External only
        if xrandr --verbose | rg -q 'HP E202'; then
            xrandr \
                --output "$HDMI" --primary --mode 1600x900 --rate 60 --rotate normal
        else
            xrandr \
                --output "$HDMI" --primary --auto --rotate normal
        fi

        bspc monitor "$HDMI" -d 1 2 3 4 5 6 7 8 9 10
    fi
else
    # Laptop only
    xrandr --output "$HDMI" --off 2>/dev/null
    xrandr --output "$EDP" --primary --mode 1366x768 --rotate normal 2>/dev/null
    bspc monitor "$EDP" -d 1 2 3 4 5 6 7 8 9 10
fi
