#!/usr/bin/env bash

if xrandr -q | grep -q '^HDMI-A-0 connected'; then
    if xrandr --verbose | grep -q 'HP E202'; then
        # Special case for the old HP monitor
        xrandr \
            --output eDP --primary --mode 1366x768 --rotate normal \
            --output HDMI-A-0 --mode 1600x900 --rate 60 --rotate normal --left-of eDP
    else
        # Generic behavior for other monitors/projectors
        xrandr \
            --output eDP --primary --mode 1366x768 --rotate normal \
            --output HDMI-A-0 --auto --rotate normal --left-of eDP
    fi

    bspc wm -O HDMI-A-0 eDP
    bspc monitor eDP -d 6 7 8 9 10
    bspc monitor HDMI-A-0 -d 1 2 3 4 5 
    # bspc monitor HDMI-A-0 -d 1 2 3 4 5 6 7 8 9 10
else
    xrandr --output HDMI-A-0 --off 2>/dev/null
    bspc monitor eDP -d 1 2 3 4 5 6 7 8 9 10
fi
