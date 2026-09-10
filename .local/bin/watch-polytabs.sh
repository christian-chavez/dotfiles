#!/usr/bin/env bash
# =============================================================================
# watch-polytabs.sh -- single controller for the [bar/pdftabs] polybar
# =============================================================================
# The "pdftabs" bar is a browser-style tab strip listing every open zathura
# window (contents drawn by polytabs.sh). This is the ONLY thing that decides
# whether that bar is on screen.
#
# ONE polybar process runs for the whole session; this script shows / hides it
# with `polybar-msg -p <pid> cmd show|hide` -- an instant map/unmap of an
# already-rendered window, no process spawn, no empty-bar flash -- and keeps
# `bspc top_padding` in step:
#
#   show  = top_padding = pdftabs bar's bottom edge (52) ; polybar-msg cmd show
#   hide  = polybar-msg cmd hide ; top_padding = MAIN bar's bottom edge (26)
#
# The two padding targets are measured once at startup and cached, so the
# reflow on a desktop switch happens in a millisecond or two.
#
# Notes:
#   * `enable-struts` is OFF on [bar/pdftabs]: under this bspwm polybar's strut
#     is folded into `bspc top_padding` and never restored on exit. The MAIN
#     bar owns top_padding (sets 26 at startup); this script only raises it
#     while the pdftabs bar is shown and lowers it back -- never to 0, or
#     windows tile over the main bar.
#   * `polybar-msg` is always targeted with `-p <pid>` so it can't also toggle
#     the main bar. polybar's hide/show is a boolean (idempotent).
#   * Event-driven (`bspc subscribe`) with a periodic safety reconcile and
#     auto-resubscribe: the subscribe socket dies on every `bspc wm -r`
#     (autorandr / reorder), and a dead daemon would strand the bar.
#
# Shown when the feature is enabled (toggle-polytabs.sh) AND the focused
# desktop on $MONITOR holds a zathura window (TRIGGER=desktop), or whenever any
# zathura is open (TRIGGER=any).
#
# Started from bspwmrc as a daemon. `watch-polytabs.sh --once` = one reconcile.
# =============================================================================

set -u

BAR='pdftabs'
MAIN_BAR='example'
MONITOR='eDP'
TRIGGER='desktop'
FALLBACK_TICK=3
PDFTABS_FALLBACK=52
MAINBAR_FALLBACK=26

RUN_DIR='/tmp'
ENABLED_FILE="$RUN_DIR/pdftabs.enabled"
DAEMON_LOCK="$RUN_DIR/pdftabs.daemon.lock"
OP_LOCK="$RUN_DIR/pdftabs.op.lock"

SHOW_PAD=''       # cached top_padding targets (measured at startup)
BASE_PAD=''

# --- queries ---------------------------------------------------------------

bar_pid() {
    local p
    p=$(pgrep -a -x polybar | awk -v b="$BAR" '
        $0 ~ "(^|[[:space:]])" b "([[:space:]]|$)" { print $1; exit }')
    [ -n "$p" ] && printf '%s\n' "$p"
}

feature_enabled() {
    [ "$(cat "$ENABLED_FILE" 2>/dev/null || echo 1)" = 1 ]
}

zathura_anywhere() {
    pgrep -x zathura >/dev/null 2>&1
}

zathura_on_focused_desktop() {
    local zids id
    zids=" $(xdotool search --class '[Zz]athura' 2>/dev/null | tr '\n' ' ')"
    [ "$zids" = " " ] && return 1
    for id in $(bspc query -N -d "${MONITOR}:focused" -n .window 2>/dev/null); do
        case "$zids" in *" $(( id )) "*) return 0 ;; esac
    done
    return 1
}

want_visible() {
    feature_enabled || return 1
    case "$TRIGGER" in
        any) zathura_anywhere ;;
        *)   zathura_on_focused_desktop ;;
    esac
}

bar_bottom() {
    local wid geo y h
    wid=$(xdotool search --name "^polybar-$1_" 2>/dev/null | head -n1) || return 1
    [ -n "$wid" ] || return 1
    geo=$(xdotool getwindowgeometry "$wid" 2>/dev/null) || return 1
    y=$(printf '%s\n' "$geo" | awk '/Position:/ { split($2, p, ","); print p[2] }')
    h=$(printf '%s\n' "$geo" | awk '/Geometry:/ { n = split($2, a, "x"); print a[n] }')
    case "$y:$h" in ''|:|*:|:*|*[!0-9:]*) return 1 ;; esac
    printf '%s\n' "$(( y + h ))"
}

set_pad() {
    [ "$(bspc config -m "$MONITOR" top_padding 2>/dev/null)" = "$1" ] && return 0
    bspc config -m "$MONITOR" top_padding "$1" 2>/dev/null || true
}

# --- polybar lifecycle ----------------------------------------------------

ensure_running() {
    bar_pid >/dev/null && return 0
    setsid -f polybar -r "$BAR" >/dev/null 2>&1 3<&- 8>&- 9>&-
    local i
    for i in $(seq 1 60); do
        bar_pid >/dev/null && break
        sleep 0.05
    done
}

msg() {   # $1 = show | hide
    local pid
    pid=$(bar_pid) || return 0
    polybar-msg -p "$pid" cmd "$1" >/dev/null 2>&1 || true
}

# --- transitions --------------------------------------------------------------

show() {
    set_pad "${SHOW_PAD:-$(bar_bottom "$BAR" 2>/dev/null || printf '%s' "$PDFTABS_FALLBACK")}"
    msg show
}

hide() {
    msg hide
    set_pad "${BASE_PAD:-$(bar_bottom "$MAIN_BAR" 2>/dev/null || printf '%s' "$MAINBAR_FALLBACK")}"
}

reconcile() {
    (
        flock 8
        if want_visible; then show; else hide; fi
    ) 8>"$OP_LOCK"
}

# --- entry points -------------------------------------------------------------

[ -f "$ENABLED_FILE" ] || echo 1 > "$ENABLED_FILE"

if [ "${1:-}" = '--once' ]; then
    reconcile
    exit 0
fi

exec 9> "$DAEMON_LOCK"
if ! flock -n 9; then
    echo "watch-polytabs.sh: another instance is already running" >&2
    exit 0
fi

trap 'msg hide; set_pad "${BASE_PAD:-$MAINBAR_FALLBACK}"; pkill -f "polybar -r $BAR" 2>/dev/null; exit 0' TERM INT

ensure_running
sleep 0.2
SHOW_PAD=$(bar_bottom "$BAR"      2>/dev/null || printf '%s' "$PDFTABS_FALLBACK")
BASE_PAD=$(bar_bottom "$MAIN_BAR" 2>/dev/null || printf '%s' "$MAINBAR_FALLBACK")
msg hide                          # start hidden; reconcile decides from here
set_pad "$BASE_PAD"
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
            ensure_running           # recover if polybar died
            reconcile
        else
            break
        fi
    done
    exec 3<&-
    sleep 1
done
