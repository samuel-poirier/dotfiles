#!/bin/bash
WS=$1

# Get monitors and find which one is currently focused
MONITORS=($(hyprctl monitors -j | jq '.[].name' -r))
WORKSPACES_PER_MONITOR=10

# Get the index of the focused monitor
FOCUSED_MONITOR=$(hyprctl monitors -j | jq '.[] | select(.focused == true) | .name' -r)
FOCUSED_INDEX=-1
for i in "${!MONITORS[@]}"; do
    if [[ "${MONITORS[$i]}" == "$FOCUSED_MONITOR" ]]; then
        FOCUSED_INDEX=$i
        break
    fi
done

TARGET_WS=$(( (FOCUSED_INDEX * WORKSPACES_PER_MONITOR) + WS ))
hyprctl dispatch movetoworkspacesilent "$TARGET_WS"

~/.config/hypr/switch-workspace.sh $1
