#!/bin/bash

key="$1"

# 1. Match the key to the text
case "$key" in
    i) text="1005215361" ;;
    c) text="8733396633" ;;
    m) text="25118952" ;;
    r) text="709875" ;;
    e) text="christian.chavez@usherbrooke.ca" ;;
    f) text="Kevin Christian Chávez Cadena" ;;
    F) text="KEVIN CHRISTIAN CHAVEZ CADENA" ;;
    n) text="Christian Chávez" ;;
    s) text="Kevin Chávez" ;;
    u) text="Université de Sherbrooke" ;;
    U) text="102-515 Wellington Sud" ;;
    M) text="christian.chr.chavez@gmail.com" ;;
    k) text="cristian78cadena123@gmail.com" ;;
    d) text="$(date "+%Y-%m-%d")" ;;
    j) text="J1H 5E2" ;;
    p) text="A9346765" ;;
	a) text="515 rue Wellington Sud, App 102, Sherbrooke Quebec, Canada, J1H 5E2" ;;
	t) text="5598220481170018" ;;
	l) text="978550051" ;;
	x) text="5598220481170018" ;;
    *) exit 1 ;;
esac

# 2. Execute the sequence EXACTLY as you had it
#    sleep -> switch layout -> type -> sleep -> restore layout
sleep 0.10
setxkbmap latam
xdotool type --delay=50 "$text"
sleep 0.10
xmodmap /home/christian/.Xmodmap
