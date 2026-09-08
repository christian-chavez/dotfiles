#!/bin/bash

# Directorio principal
DIR="/mnt/Mis archivos/maitrise"
DIR2="/mnt/Mis archivos/Google Drive/graduate applications/Sherbrooke"

# Si alguna vez quieres buscar en ambos al mismo tiempo, puedes usar:
# DIR1="/mnt/Mis archivos/maitrise"
# DIR2="/mnt/Mis archivos/Google Drive/Libros"
# Y pasar ambos a rg: rg --files -g '*.pdf' "$DIR1" "$DIR2"

file=$(rg --files -g '*.pdf' "$DIR" "$DIR2" 2>/dev/null \
    | awk -F/ '{printf "%s                                                                                               :::%s\n", $NF, $0}' \
    | rofi -normal-window -threads 0 -dmenu -i -normalize-match -p 'Files:' \
    | awk -F ':::' '{print $2}')

[ -n "$file" ] && xdg-open "$file"
