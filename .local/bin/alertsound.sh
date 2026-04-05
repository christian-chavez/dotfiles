#!/bin/sh
paplay --stream-name='battery-alert' --volume=65536 "$HOME/.local/bin/power-low-louder.wav" >/dev/null 2>&1 &
# paplay --stream-name='battery-alert' --volume=65536 "$HOME/.local/bin/power-low.oga" >/dev/null 2>&1 &


# mpv --no-config --no-video --really-quiet /home/christian/.local/bin/power-unplug.oga >/dev/null 2>&1 &
# mpv --no-config --no-video --really-quiet /home/christian/.local/bin/lowww.mp3 >/dev/null 2>&1 &
# mpv --no-config --no-video --really-quiet /home/christian/.local/bin/alert.wav >/dev/null 2>&1 &
