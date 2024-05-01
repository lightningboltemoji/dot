#!/bin/sh

if [ "$FOCUSED_WORKSPACE" == "off" ]; then
    sketchybar --set $NAME icon="" label.drawing="off"
else
    sketchybar --set $NAME icon="" label.drawing="on" label="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"
fi
