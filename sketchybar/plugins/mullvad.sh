#!/bin/sh

STATUS=$(/usr/local/bin/mullvad status)
DRAWING="on"
case $STATUS in
  Connected*) ICON="󰱓"
  ;;
  Disconnected) DRAWING="off"
  ;;
  *) ICON="󰛵"
esac

sketchybar --set $NAME drawing="$DRAWING" icon="$ICON" label="$STATUS"