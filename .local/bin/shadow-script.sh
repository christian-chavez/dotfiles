#!/bin/bash
# shadow-script.sh -- picom shadows for floating and pseudo-tiled windows.
#
# picom.conf leaves out the shadow on every window without _COMPTON_SHADOW = 1
# (rofi excepted). This sets that flag on bspwm's floating and pseudo-tiled
# windows and clears it on the rest (tiled, monocle, fullscreen).
#
# On every window event it re-reads bspwm's state, instead of reacting to
# single "floating on/off" changes: windows that open floating (bspwm rules,
# dialogs) and windows that existed before this script started get the
# shadow too. Started from bspwmrc.

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/shadow-script.lock"
flock -n 9 || exit 0      # one instance, however often bspwmrc is reloaded

declare -A marked         # windows this script has flagged

# $1 = full: also clear the flag on windows this script didn't flag itself
sync_flags() {
    local -A want=()
    local n
    for n in $(bspc query -N -n .window.floating 2>/dev/null) \
             $(bspc query -N -n .window.pseudo_tiled 2>/dev/null); do
        want[$n]=1
    done
    for n in "${!want[@]}"; do
        [ -n "${marked[$n]:-}" ] && continue
        xprop -id "$n" -f _COMPTON_SHADOW 32c -set _COMPTON_SHADOW 1 2>/dev/null
        marked[$n]=1
    done
    if [ "${1:-}" = full ]; then
        for n in $(bspc query -N -n .window 2>/dev/null); do
            [ -n "${want[$n]:-}" ] || xprop -id "$n" -remove _COMPTON_SHADOW 2>/dev/null
        done
    fi
    for n in "${!marked[@]}"; do
        [ -n "${want[$n]:-}" ] && continue
        xprop -id "$n" -remove _COMPTON_SHADOW 2>/dev/null
        unset 'marked[$n]'
    done
}

# reconnect if bspwm restarts (`bspc wm -r` closes the subscription)
while :; do
    sync_flags full
    bspc subscribe node_add node_remove node_state 2>/dev/null |
        while read -r _; do sync_flags; done
    sleep 1
done
