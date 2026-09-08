#!/bin/bash

# Configuration
LOG_FILE="/home/christian/Documents/obsidian-vaults/Test/Zettelkasten/messure of reading wander.md"

# 1. Ask when to start
echo "Ready to track your reading session?"
read -p "Press [ENTER] to start the session..."

# Capture start time for display and for math
START_DATE_DISPLAY=$(date "+%Y-%m-%d %H:%M:%S")
START_SECONDS=$(date +%s)

echo -e "\n---" >> "$LOG_FILE"
echo -e "### Session Start: $START_DATE_DISPLAY\n" >> "$LOG_FILE"

echo "Session started at $START_DATE_DISPLAY."
echo "Press [SPACE] every time your mind wanders."
echo "Press [Q] to end the session."

# 2. Listen for input
while : ; do
    read -s -n 1 key
    
    if [[ "$key" == "" ]]; then
        TIMESTAMP=$(date +"%Hh%Mm%S")
        echo "* Mind wandered at: $TIMESTAMP" >> "$LOG_FILE"
        echo "Logged: $TIMESTAMP"
    fi

    if [[ "$key" == "q" || "$key" == "Q" ]]; then
        break
    fi
done

# 3. Mark the end and calculate duration
END_DATE_DISPLAY=$(date "+%Y-%m-%d %H:%M:%S")
END_SECONDS=$(date +%s)

# Math: Total seconds = End - Start
SECONDS_DIFF=$(( END_SECONDS - START_SECONDS ))

# Formatting the seconds into HH:MM:SS
FORMATTED_DURATION=$(printf '%02dh %02dm %02ds\n' $((SECONDS_DIFF/3600)) $((SECONDS_DIFF%3600/60)) $((SECONDS_DIFF%60)))

echo -e "\n**Total Duration:** $FORMATTED_DURATION" >> "$LOG_FILE"
echo -e "END at '$END_DATE_DISPLAY'" >> "$LOG_FILE"

echo -e "\nSession finished."
echo "Total time: $FORMATTED_DURATION"
