#!/bin/bash

# Directorios donde buscar (se ignoran los que no existan)
DIRS=(
    "/home/christian/Documents/maitrise"
    "/mnt/Mis archivos/Google Drive/graduate applications/Sherbrooke"
)

# Nos quedamos solo con los directorios que existen
search_dirs=()
for d in "${DIRS[@]}"; do
    [ -d "$d" ] && search_dirs+=("$d")
done

[ ${#search_dirs[@]} -eq 0 ] && {
    notify-send "rofi-files" "Ninguno de los directorios de búsqueda existe" 2>/dev/null
    exit 1
}

# Busca recursivamente todos los PDF bajo esos directorios.
# Se muestra el nombre del archivo y, tras ':::', la ruta completa (oculta) que
# rofi usa al abrir. -i / -normalize-match hacen que el filtro sea insensible a
# mayúsculas y acentos, así coincide con lo que escribas.
file=$(rg --files -g '*.pdf' "${search_dirs[@]}" 2>/dev/null \
    | awk -F/ '{printf "%s%100s:::%s\n", $NF, "", $0}' \
    | rofi -normal-window -threads 0 -dmenu -i -normalize-match -p 'Files:' \
    | awk -F ':::' '{print $2}')

[ -n "$file" ] && xdg-open "$file"
