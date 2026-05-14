#!/bin/bash
WS=$1

# Get monitor count and names in order
MONITORS=($(hyprctl monitors -j | jq '.[].name' -r))
NUM_MONITORS=${#MONITORS[@]}
WORKSPACES_PER_MONITOR=10

# Store the focused monitor before switching
FOCUSED_MONITOR=$(hyprctl monitors -j | jq '.[] | select(.focused == true) | .name' -r)

for i in "${!MONITORS[@]}"; do
    TARGET_WS=$(( (i * WORKSPACES_PER_MONITOR) + WS ))
    hyprctl dispatch focusmonitor "${MONITORS[$i]}"
    hyprctl dispatch workspace "$TARGET_WS"
done

# Return focus to the monitor where the script was executed
hyprctl dispatch focusmonitor "$FOCUSED_MONITOR"
