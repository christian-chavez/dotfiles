#!/usr/bin/env bash

set -euo pipefail

file="${1:?Usage: xopp-watch-pdf file.xopp}"

file="$(realpath "$file")"
dir="$(dirname "$file")"
base="$(basename "$file")"

out="$dir/$base.pdf"
tmp="$dir/.$base.tmp.pdf"

wait_until_stable() {
    local old new

    old="$(stat -c '%s %Y' "$file")"

    while true; do
        sleep 0.5
        new="$(stat -c '%s %Y' "$file")"

        [[ "$old" == "$new" ]] && break
        old="$new"
    done
}

export_pdf() {
    wait_until_stable

    echo "Exporting: $base -> $base.pdf"

    xournalpp -p "$tmp" "$file"
    mv -f "$tmp" "$out"
}

export_pdf

inotifywait -m -e close_write,moved_to "$dir" --format '%f' |
while read -r changed; do
    [[ "$changed" == "$base" ]] || continue

    export_pdf
done
