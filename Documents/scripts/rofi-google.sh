#!/bin/bash

query=$(rofi -no-click-to-exit -dmenu -p "Google " -lines 1 -theme-str 'listview { lines: 0; fixed-height: 0; }' </dev/null)

if [ -n "$query" ]; then
    xdg-open "https://www.google.com/search?q=$(printf %s "$query" | sed 's/[[:space:]]\+/+/g')" &
fi

