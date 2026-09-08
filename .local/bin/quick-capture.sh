#!/bin/bash

SAVE_DIR="$HOME/Pictures/Screenshots/vocab"
mkdir -p "$SAVE_DIR"

# 1. Start region selection immediately
# No "Press Enter" prompt here so it goes straight to the GUI
flameshot gui -p "$SAVE_DIR" > /dev/null 2>&1

# 2. Show the "Region locked" message and filename on one line
LATEST_FILE=$(ls -t "$SAVE_DIR" | head -n1)
echo "Region locked."
echo "Saved: $LATEST_FILE"

# 3. Loop for all subsequent snaps
while true; do
    # Display the prompt at the very bottom
    read -p "Press [ENTER] to snap..."
    
    # Take the snapshot
    flameshot full -p "$SAVE_DIR" > /dev/null 2>&1
    
    # Get the newest filename
    LATEST_FILE=$(ls -t "$SAVE_DIR" | head -n1)
    
    # THE FIX: Move UP 1 line and CLEAR that line
    # This overwrites the "Press [ENTER]..." prompt with the filename
    printf "\033[1A\033[K"
    
    # Print the saved filename as a single permanent line
    echo "Saved: $LATEST_FILE"
done
