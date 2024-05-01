#!/bin/sh

STATUS=$(/usr/local/bin/mullvad status | head -n 1)
DRAWING="on"
case $STATUS in
Connected*)
	ICON="󰱓"
	;;
Disconnected)
	DRAWING="off"
	;;
*) ICON="󰛵" ;;
esac

sketchybar --set $NAME drawing="$DRAWING" icon="$ICON" label="$STATUS"

