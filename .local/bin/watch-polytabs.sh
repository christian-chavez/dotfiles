#!/usr/bin/env bash
# =============================================================================
# watch-polytabs.sh -- single controller for the pdftabs polybars
# =============================================================================
# The "pdftabs" bars are browser-style tab strips listing every open zathura
# window (contents drawn by polytabs.sh). This is the ONLY thing that decides
# whether those bars are on screen. There is one per monitor (see BARS):
# [bar/pdftabs] on eDP, [bar/pdftabs-ext] on HDMI-A-0.
#
# ONE polybar process per active monitor runs for the whole session; this
# script shows / hides it with `polybar-msg -p <pid> cmd show|hide` -- an
# instant map/unmap of an already-rendered window, no process spawn, no
# empty-bar flash -- and keeps that monitor's `bspc top_padding` in step:
#
#   show  = top_padding = pdftabs bar's bottom edge (58) ; polybar-msg cmd show
#   hide  = polybar-msg cmd hide ; top_padding = MAIN bar's bottom edge (29)
#
# The padding targets are measured once at startup and cached, so the
# reflow on a desktop switch happens in a millisecond or two.
#
# Notes:
#   * `enable-struts` is OFF on the pdftabs bars: under this bspwm polybar's
#     strut is folded into `bspc top_padding` and never restored on exit. The
#     MAIN bar owns top_padding (sets 29 at startup); this script only raises it
#     while a pdftabs bar is shown and lowers it back -- never to 0, or
#     windows tile over the main bar.
#   * `polybar-msg` is always targeted with `-p <pid>` so it can't also toggle
#     the main bars. polybar's hide/show is a boolean (idempotent).
#   * Event-driven (`bspc subscribe`) with a periodic safety reconcile and
#     auto-resubscribe: the subscribe socket dies on every `bspc wm -r`
#     (autorandr / reorder), and a dead daemon would strand the bar.
#   * The set of active monitors is read once at startup: every monitor change
#     ends in `bspc wm -r`, and bspwmrc then restarts this daemon.
#
# A monitor's bar is shown when the feature is enabled (toggle-polytabs.sh)
# AND the focused desktop on that monitor holds a zathura window
# (TRIGGER=desktop), or whenever any zathura is open (TRIGGER=any).
#
# Started from bspwmrc as a daemon. `watch-polytabs.sh --once` = one reconcile.
# =============================================================================

set -u

# monitor:pdftabs bar:main bar on that monitor
BARS='eDP:pdftabs:example HDMI-A-0:pdftabs-ext:external'
TRIGGER='desktop'
FALLBACK_TICK=3
PDFTABS_FALLBACK=58
MAINBAR_FALLBACK=29

RUN_DIR='/tmp'
ENABLED_FILE="$RUN_DIR/pdftabs.enabled"
DAEMON_LOCK="$RUN_DIR/pdftabs.daemon.lock"
OP_LOCK="$RUN_DIR/pdftabs.op.lock"

ACTIVE=()                       # BARS entries whose monitor is connected
declare -A SHOW_PAD=() BASE_PAD=()   # cached top_padding targets, per monitor

# --- queries ---------------------------------------------------------------

active_entries() {
    local mons e
    mons=" $(xrandr --listactivemonitors 2>/dev/null | awk 'NR > 1 { printf "%s ", $NF }')"
    for e in $BARS; do
        case "$mons" in *" ${e%%:*} "*) printf '%s\n' "$e" ;; esac
    done
}

bar_pid() {   # $1 = bar
    local p
    p=$(pgrep -a -x polybar | awk -v b="$1" '
        $0 ~ "(^|[[:space:]])" b "([[:space:]]|$)" { print $1; exit }')
    [ -n "$p" ] && printf '%s\n' "$p"
}

feature_enabled() {
    [ "$(cat "$ENABLED_FILE" 2>/dev/null || echo 0)" = 1 ]
}

zathura_anywhere() {
    pgrep -x zathura >/dev/null 2>&1
}

zathura_on_focused_desktop() {   # $1 = monitor
    local zids id
    zids=" $(xdotool search --class '[Zz]athura' 2>/dev/null | tr '\n' ' ')"
    [ "$zids" = " " ] && return 1
    for id in $(bspc query -N -d "${1}:focused" -n .window 2>/dev/null); do
        case "$zids" in *" $(( id )) "*) return 0 ;; esac
    done
    return 1
}

want_visible() {   # $1 = monitor
    feature_enabled || return 1
    case "$TRIGGER" in
        any) zathura_anywhere ;;
        *)   zathura_on_focused_desktop "$1" ;;
    esac
}

bar_bottom() {   # $1 = bar
    local wid geo y h
    wid=$(xdotool search --name "^polybar-$1_" 2>/dev/null | head -n1) || return 1
    [ -n "$wid" ] || return 1
    geo=$(xdotool getwindowgeometry "$wid" 2>/dev/null) || return 1
    y=$(printf '%s\n' "$geo" | awk '/Position:/ { split($2, p, ","); print p[2] }')
    h=$(printf '%s\n' "$geo" | awk '/Geometry:/ { n = split($2, a, "x"); print a[n] }')
    case "$y:$h" in ''|:|*:|:*|*[!0-9:]*) return 1 ;; esac
    printf '%s\n' "$(( y + h ))"
}

set_pad() {   # $1 = monitor, $2 = padding
    [ "$(bspc config -m "$1" top_padding 2>/dev/null)" = "$2" ] && return 0
    bspc config -m "$1" top_padding "$2" 2>/dev/null || true
}

# --- polybar lifecycle ----------------------------------------------------

ensure_running() {   # $1 = bar
    bar_pid "$1" >/dev/null && return 0
    setsid -f polybar -r "$1" >/dev/null 2>&1 3<&- 8>&- 9>&-
    # wait until polybar has mapped its window, not just until the process
    # exists: a `hide` that arrives before that first map is recorded, the
    # window gets mapped anyway, and every later `hide` is then ignored (the
    # bar thinks it is already hidden) -- an empty black strip under the main bar
    local i
    for i in $(seq 1 100); do
        xdotool search --onlyvisible --name "^polybar-${1}_" >/dev/null 2>&1 && break
        sleep 0.05
    done
}

msg() {   # $1 = bar, $2 = show | hide
    local pid
    pid=$(bar_pid "$1") || return 0
    polybar-msg -p "$pid" cmd "$2" >/dev/null 2>&1 || true
}

# --- transitions --------------------------------------------------------------

show() {   # $1 = monitor, $2 = pdftabs bar
    set_pad "$1" "${SHOW_PAD[$1]:-$(bar_bottom "$2" 2>/dev/null || printf '%s' "$PDFTABS_FALLBACK")}"
    msg "$2" show
}

hide() {   # $1 = monitor, $2 = pdftabs bar, $3 = main bar
    msg "$2" hide
    set_pad "$1" "${BASE_PAD[$1]:-$(bar_bottom "$3" 2>/dev/null || printf '%s' "$MAINBAR_FALLBACK")}"
}

reconcile() {
    (
        flock 8
        local e mon bar main
        for e in "${ACTIVE[@]}"; do
            IFS=: read -r mon bar main <<<"$e"
            if want_visible "$mon"; then show "$mon" "$bar"; else hide "$mon" "$bar" "$main"; fi
        done
    ) 8>"$OP_LOCK"
}

shutdown() {
    local e mon bar main
    for e in "${ACTIVE[@]}"; do
        IFS=: read -r mon bar main <<<"$e"
        msg "$bar" hide
        set_pad "$mon" "${BASE_PAD[$mon]:-$MAINBAR_FALLBACK}"
    done
    # every bar in BARS, not only the active ones: also reap a bar left
    # behind on a monitor that has since been unplugged
    for e in $BARS; do
        IFS=: read -r mon bar main <<<"$e"
        pkill -xf "polybar -r $bar" 2>/dev/null
    done
    exit 0
}

# --- entry points -------------------------------------------------------------

[ -f "$ENABLED_FILE" ] || echo 0 > "$ENABLED_FILE"
mapfile -t ACTIVE < <(active_entries)

if [ "${1:-}" = '--once' ]; then
    reconcile
    exit 0
fi

exec 9> "$DAEMON_LOCK"
if ! flock -n 9; then
    echo "watch-polytabs.sh: another instance is already running" >&2
    exit 0
fi

trap shutdown TERM INT

for e in "${ACTIVE[@]}"; do
    IFS=: read -r mon bar main <<<"$e"
    ensure_running "$bar"
done
sleep 0.2
for e in "${ACTIVE[@]}"; do
    IFS=: read -r mon bar main <<<"$e"
    SHOW_PAD[$mon]=$(bar_bottom "$bar"  2>/dev/null || printf '%s' "$PDFTABS_FALLBACK")
    BASE_PAD[$mon]=$(bar_bottom "$main" 2>/dev/null || printf '%s' "$MAINBAR_FALLBACK")
    msg "$bar" hide               # start hidden; reconcile decides from here
    set_pad "$mon" "${BASE_PAD[$mon]}"
done
reconcile

while :; do
    exec 3< <(bspc subscribe desktop_focus monitor_focus \
                   node_add node_remove node_transfer node_swap 2>/dev/null)
    while :; do
        read -t "$FALLBACK_TICK" -r ev <&3
        rc=$?
        if [ "$rc" -eq 0 ]; then
            case "$ev" in node_add*) sleep 0.05 ;; esac
            reconcile
        elif [ "$rc" -gt 128 ]; then
            for e in "${ACTIVE[@]}"; do   # recover if a polybar died
                IFS=: read -r mon bar main <<<"$e"
                ensure_running "$bar"
            done
            reconcile
        else
            break
        fi
    done
    exec 3<&-
    sleep 1
done
