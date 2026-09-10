#!/usr/bin/env bash
# Keep the Wacom Intuos BT S mapped correctly whenever it is connected --
# over USB or Bluetooth -- so it no longer needs a manual keybind.
#
# Started once from bspwmrc:
#     pgrep -f '[w]acom-watch.sh' >/dev/null || "$HOME/.local/bin/wacom-watch.sh" &
#
# It polls every INTERVAL seconds. Rather than firing only on an absent ->
# present edge, it checks, while the tablet is present, whether the mapping is
# actually in place (pad Button 1 == the expected keystroke) and runs
# wacom-map.sh if not. That self-heals every case the edge approach missed: a
# Bluetooth <-> USB switch where the device never looks fully absent, X reusing
# the same input id with stale or default bindings, and a replug that lands
# inside one poll window. When the tablet is absent it does nothing. Polling is
# used (not a udev hook) because a reconnect creates the X input device at an
# unpredictable moment after the kernel event -- the same approach
# auto-bt-audio.sh already uses.

MAP="$HOME/.local/bin/wacom-map.sh"
PAD='Wacom Intuos BT S Pad pad'
EXPECT='Control_L'          # substring of `xsetwacom get <pad> Button 1` once mapped
INTERVAL=2

pad_ids() {
	xsetwacom --list devices 2>/dev/null | grep -F "$PAD" | grep -oP 'id:\s*\K[0-9]+'
}

needs_map() {
	local ids id got
	ids=$(pad_ids) || return 1
	[ -z "$ids" ] && return 1                     # tablet not connected -> nothing to do
	for id in $ids; do
		got=$(xsetwacom get "$id" Button 1 2>/dev/null)
		[[ $got == *"$EXPECT"* ]] || return 0     # a pad is unmapped -> (re)apply
	done
	return 1                                      # all pads already mapped
}

while :; do
	needs_map && "$MAP"
	sleep "$INTERVAL"
done
