#!/bin/sh

if [ "$FOCUSED_WORKSPACE" == "off" ]; then
	sketchybar --set $NAME label="󰏤"
else
	sketchybar --set $NAME icon="" label="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"
fi
