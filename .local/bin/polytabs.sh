#!/usr/bin/env bash
# =============================================================================
# polytabs.sh -- content for the [bar/pdftabs] polybar module (zathura "tabs")
# =============================================================================
# Prints one clickable label per open zathura window; left-click focuses that
# window. The window that currently holds X input focus is underlined and
# brightened. This script does NOT show or hide the bar -- watch-polytabs.sh
# is the only thing that does that.
# =============================================================================

set -u

MAXLEN=23         # trim titles longer than this...
KEEP=20           # ...down to this many chars + an ellipsis

FOCUS='#63b1ff'   # active tab  (foreground + underline)
DIM='#707880'     # inactive tabs

active=$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | awk 'NF { print $NF }')
case "$active" in ''|0x0) active=0 ;; esac
active=$(( active ))

out=''
while read -r id _ cls _ title; do
    case "$cls" in *[Zz]athura*) ;; *) continue ;; esac

    name=$(basename -- "$title")
    name=${name% - zathura}
    case "$name" in ''|'zathura'|'[No name]') continue ;; esac

    if [ "${#name}" -gt "$MAXLEN" ]; then
        name="${name:0:KEEP}…"
    fi

    if [ "$(( id ))" -eq "$active" ]; then
        label="%{F$FOCUS}%{u$FOCUS}%{+u}  $name  %{-u}%{F-}"
    else
        label="%{F$DIM}  $name  %{F-}"
    fi
    out="$out%{A1:wmctrl -ia $id:}$label%{A}"
done < <(wmctrl -lx 2>/dev/null | grep -i 'zathura')

printf '%s\n' "$out"
