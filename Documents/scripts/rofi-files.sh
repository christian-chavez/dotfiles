#!/bin/bash
file=$(find /mnt/Mis\ archivos/maitrise -type f -name '*.pdf' -print0 | while IFS= read -r -d '' path; do echo "$(basename "$path")                                                                                                                :::$path"; done | rofi -normal-window -threads 0 -dmenu -i -p 'Files:' | awk -F ':::' '{print $2}') && [ -n "$file" ] && xdg-open "$file"

# file=$(find /mnt/Mis\ archivos/Google\ Drive/Libros -type f -name '*.pdf' -print0 | while IFS= read -r -d '' path; do echo "$(basename "$path")                                                                                                                :::$path"; done | rofi -threads 0 -dmenu -i -p 'Files:' | awk -F ':::' '{print $2}') && [ -n "$file" ] && xdg-open "$file"
