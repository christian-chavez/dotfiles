#!/usr/bin/env bash

set -euo pipefail

VAULT_DIR='/home/christian/Documents/obsidian-vaults/Test/Zettelkasten'

if [ $# -eq 0 ]; then
  read -r -p 'Title: ' note_name
else
  note_name="$*"
fi

while [ -z "${note_name// }" ]; do
  read -r -p 'Title cannot be empty. Title: ' note_name
done

case "$note_name" in
  *.md) filename="$note_name" ;;
  *)    filename="$note_name.md" ;;
esac

mkdir -p "$VAULT_DIR"

filepath="$VAULT_DIR/$filename"

if [ ! -e "$filepath" ]; then
  timestamp="$(date '+%Y-%m-%d-%H-%M-%S')"

  cat > "$filepath" <<EOF
---
date: $timestamp
tags: 
  - 
---


EOF
fi

nvim +'normal! G' "$filepath"
