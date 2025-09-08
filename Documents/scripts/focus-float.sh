#!/bin/bash --

while bspc subscribe --count 1 node_focus > /dev/null; do
        bspc node focused.floating --layer above
        bspc node focused.floating --layer normal
done
