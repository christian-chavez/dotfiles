#!/bin/bash
# shadow-script.sh -- picom shadows for floating and pseudo-tiled windows.
#
# Sets _COMPTON_SHADOW = 1 on bspwm's floating and pseudo-tiled windows and
# _COMPTON_SHADOW = 0 on the rest (tiled, monocle, fullscreen). picom handles
# that property natively: 0 = no shadow, re-read on every change. (Matching it
# in a shadow-exclude rule instead is unreliable -- picom v13 caches the rule's
# value, so a window that turned floating after it opened got no shadow.)
# bspwm's external_rules pre-sets the flag before a new window maps, so it
# opens with the right shadow; this script corrects it on any later change.
#
# On every window event it re-reads bspwm's state, instead of reacting to
# single "floating on/off" changes: windows that open floating (bspwm rules,
# dialogs) and windows that existed before this script started get the
# shadow too. Started from bspwmrc.

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/shadow-script.lock"
flock -n 9 || exit 0      # one instance, however often bspwmrc is reloaded

declare -A flag           # window -> flag value this script last set (0 / 1)

sync_flags() {
    local -A want=() have=()
    local n v
    for n in $(bspc query -N -n .window.floating 2>/dev/null) \
             $(bspc query -N -n .window.pseudo_tiled 2>/dev/null); do
        want[$n]=1
    done
    for n in $(bspc query -N -n .window 2>/dev/null); do
        have[$n]=1
        v=${want[$n]:-0}
        [ "${flag[$n]:-}" = "$v" ] && continue
        xprop -id "$n" -f _COMPTON_SHADOW 32c -set _COMPTON_SHADOW "$v" 2>/dev/null
        flag[$n]=$v
    done
    # forget closed windows -- X reuses window ids
    for n in "${!flag[@]}"; do
        [ -n "${have[$n]:-}" ] || unset 'flag[$n]'
    done
}

# reconnect if bspwm restarts (`bspc wm -r` closes the subscription). The
# subscriber loop runs in a subshell, so its cache never reaches this shell:
# start each round from scratch and set every window's flag again.
while :; do
    flag=()
    sync_flags
    bspc subscribe node_add node_remove node_state 2>/dev/null |
        while read -r _; do sync_flags; done
    sleep 1
done
