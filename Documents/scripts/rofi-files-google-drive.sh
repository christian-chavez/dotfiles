#!/bin/bash

# Define the directory to keep things clean
DIR="/mnt/Mis archivos/Google Drive/Libros"

# 1. rg --files: Quickly lists all files
# 2. awk: Formats the output in milliseconds (replaces the slow while loop + basename)
# 3. rofi: Shows the menu
# 4. awk: Extracts the path

file=$(rg --files "$DIR" 2>/dev/null \
    | awk -F/ '{printf "%s                                                                                               :::%s\n", $NF, $0}' \
    | rofi -normal-window -threads 0 -dmenu -i -p "Files:" \
    | awk -F ':::' '{print $2}')

# Open the file if one was selected
[ -n "$file" ] && xdg-open "$file"
