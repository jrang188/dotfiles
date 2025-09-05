#!/bin/bash

echo "=== Current Monitor Setup ==="
echo "Aerospace monitors:"
aerospace list-monitors --json

echo -e "\nAerospace workspaces with monitor IDs:"
aerospace list-workspaces --all --format '%{workspace}%{monitor-appkit-nsscreen-screens-id}' --json

echo -e "\nSystem displays:"
system_profiler SPDisplaysDataType | grep -A 3 -B 1 "Display Type\|Resolution"

echo -e "\nSketchyBar display info:"
sketchybar --query bar | jq '.display' 2>/dev/null || echo "SketchyBar not running or jq not available"
