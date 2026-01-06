#!/bin/bash

BT_SINK="bluez_output.24_14_1F_E5_C4_B2.1"
DEFAULT_SINK="effect_input.virtual-surround-7.1-hesuvi"
# DEFAULT_SINK="alsa_output.pci-0000_04_00.6.analog-stereo"

while true; do
    # Check if the Bluetooth sink exists (device connected)
    if pactl list short sinks | grep -q "$BT_SINK"; then
        CURRENT_SINK=$(pactl info | grep "Default Sink" | awk '{print $3}')
        if [ "$CURRENT_SINK" != "$BT_SINK" ]; then
            echo "🔊 Switching to Bluetooth sink: $BT_SINK"
            pactl set-default-sink "$BT_SINK"
        fi
    else
        # Bluetooth sink not found → switch back to default speakers
        CURRENT_SINK=$(pactl info | grep "Default Sink" | awk '{print $3}')
        if [ "$CURRENT_SINK" != "$DEFAULT_SINK" ]; then
            echo "🎧 Bluetooth disconnected — switching to speakers: $DEFAULT_SINK"
            pactl set-default-sink "$DEFAULT_SINK"
        fi
    fi
    sleep 5
done

