#!/usr/bin/env bash
# Map the Wacom Intuos BT S (pad + stylus) to the built-in laptop screen and
# set the pad button bindings.
#
# Run automatically on connect by wacom-watch.sh (started from bspwmrc); also
# safe to run by hand. Replaces the old manual scripts xsetwacom-new.sh /
# xsetwacom-new-laptop.sh that used to be bound to super+shift+x.
#
# It retries for a few seconds because X registers the tablet's input devices
# a moment *after* the udev add event fires, whether it arrived over USB or
# Bluetooth.

OUTPUT='eDP'
PAD='Wacom Intuos BT S Pad pad'
STYLUS='Wacom Intuos BT S Pen stylus'

apply() {
	mapfile -t pads  < <(xsetwacom --list devices | grep -F "$PAD"    | grep -oP 'id:\s*\K[0-9]+')
	mapfile -t styli < <(xsetwacom --list devices | grep -F "$STYLUS" | grep -oP 'id:\s*\K[0-9]+')
	[ ${#pads[@]} -eq 0 ] && [ ${#styli[@]} -eq 0 ] && return 1

	for i in "${pads[@]}"; do
		xsetwacom set "$i" MapToOutput "$OUTPUT"
		xsetwacom set "$i" Button 1 key +CTRL z   # undo
		xsetwacom set "$i" Button 2 key 0xFF55    # Page Up
		xsetwacom set "$i" Button 3 key 0xFF61    # Print
	done
	for i in "${styli[@]}"; do
		xsetwacom set "$i" MapToOutput "$OUTPUT"
	done
	return 0
}

for _ in $(seq 1 20); do
	apply && exit 0
	sleep 0.5
done
exit 1
