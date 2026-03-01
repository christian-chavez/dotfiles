#!/usr/bin/env bash

set -euo pipefail

VAULT_DIR='/home/christian/Documents/obsidian-vaults/Test/Zettelkasten'

if [ $# -lt 1 ]; then
  echo 'Usage: zvim <note name>'
  exit 1
fi

note_name="$*"

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
---


EOF
fi

nvim +'normal! G' "$filepath"
