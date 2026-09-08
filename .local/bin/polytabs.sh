#!/bin/bash

# 1. Check if Zathura is even running
if ! pgrep -x "zathura" > /dev/null; then
    # Tell Polybar to hide this specific bar
    polybar-msg -p $(pgrep -a polybar | grep "example-lower" | awk '{print $1}') cmd hide > /dev/null 2>&1
    exit 0
else
    # Tell Polybar to show the bar if Zathura is found
    polybar-msg -p $(pgrep -a polybar | grep "example-lower" | awk '{print $1}') cmd show > /dev/null 2>&1
fi

active_window=$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | awk '{print $5}')
[ -z "$active_window" ] && active_window="0x0"

output=""

while read -r id _ cls _ title; do

    # 1. Strip path and " - zathura" suffix
    clean_title=$(basename "$title" | sed 's/ - zathura//g')

    # 2. Limit to 30 characters
    # If the length is greater than 30, cut it and add "..."
    if [ ${#clean_title} -gt 23 ]; then
        display_name="${clean_title:0:20}..."
    else
        display_name="$clean_title"
    fi

    # 3. Formatting
    if [ $((id)) -eq $((active_window)) ]; then
        label="%{F#63b1ff}%{u#63b1ff}%{+u} $display_name %{-u}%{F-}"
    else
        label="%{F#707880} $display_name %{F-}"
    fi

    output="$output%{A1:wmctrl -ia $id:}$label%{A}"

done < <(wmctrl -lx | grep -i "zathura")

echo "$output"
