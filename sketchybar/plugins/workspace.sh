#!/bin/sh

if [ "$WORKSPACE" == "off" ]; then
  sketchybar --set $NAME label="󰏤"
else
  sketchybar --set $NAME icon="" label="${WORKSPACE:-$(aerospace list-workspaces --focused)}"
fi
