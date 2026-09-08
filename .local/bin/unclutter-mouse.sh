#!/bin/sh
exec > /tmp/unclutter.log 2>&1

date
echo "DISPLAY=$DISPLAY"
echo "XAUTHORITY=$XAUTHORITY"
echo "whoami=$(whoami)"

unclutter --timeout 3 --jitter 5 --ignore-scrolling --fork
echo "unclutter exit code: $?"
