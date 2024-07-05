idspad=($(xsetwacom --list devices | grep "Wacom Intuos BT S Pad pad" | awk '{print $8}'))
idsstylus=($(xsetwacom --list devices | grep "Wacom Intuos BT S Pen stylus" | awk '{print $8}'))

for i in "${idspad[@]}"
do
        xsetwacom set $i MapToOutput eDP
        xsetwacom set $i Button 1 key +CTRL z
        xsetwacom set $i Button 2 key +CTRL v
        xsetwacom set $i Button 3 key 0xFF61
done

for i in "${idsstylus[@]}"
do
        xsetwacom set $i MapToOutput eDP
done
