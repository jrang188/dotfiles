#!/bin/bash

echo "=== SketchyBar Workspace Monitor Fix ==="
echo "This script helps debug and fix workspace monitor assignments"
echo ""

# Function to restart sketchybar
restart_sketchybar() {
    echo "Restarting SketchyBar..."
    pkill -f sketchybar
    sleep 2
    sketchybar &
    echo "SketchyBar restarted"
}

# Function to show current monitor setup
show_monitor_setup() {
    echo "=== Current Monitor Setup ==="
    echo ""
    echo "1. Aerospace monitors:"
    aerospace list-monitors --json | jq '.'
    
    echo ""
    echo "2. Workspaces with monitor IDs:"
    aerospace list-workspaces --all --format '%{workspace}%{monitor-appkit-nsscreen-screens-id}' --json | jq '.'
    
    echo ""
    echo "3. Workspaces with monitor names:"
    aerospace list-workspaces --all --format '%{workspace}%{monitor-name}' --json | jq '.'
    
    echo ""
    echo "4. System displays:"
    system_profiler SPDisplaysDataType | grep -A 3 -B 1 "Display Type\|Resolution"
}

# Function to test workspace assignments
test_workspace_assignments() {
    echo ""
    echo "=== Testing Workspace Assignments ==="
    
    # Get current workspace
    current_workspace=$(aerospace list-workspaces --focused)
    echo "Current focused workspace: $current_workspace"
    
    # Test switching to different workspaces
    echo "Testing workspace switching..."
    for workspace in 1 2 3; do
        echo "Switching to workspace $workspace..."
        aerospace workspace $workspace
        sleep 1
        current_monitor=$(aerospace list-monitors --focused | awk '{print $1}')
        echo "  -> Now on monitor: $current_monitor"
    done
    
    # Return to original workspace
    aerospace workspace $current_workspace
    echo "Returned to workspace $current_workspace"
}

# Function to apply the fix
apply_fix() {
    echo ""
    echo "=== Applying Workspace Monitor Fix ==="
    
    # Backup original file
    cp items/workspaces.lua items/workspaces.lua.backup
    echo "Backed up original workspaces.lua to workspaces.lua.backup"
    
    # Restart sketchybar to apply changes
    restart_sketchybar
    
    echo "Fix applied! Check the SketchyBar logs for monitor assignment debug info."
    echo "You can view logs with: tail -f ~/.sketchybar.log"
}

# Main menu
case "${1:-menu}" in
    "show")
        show_monitor_setup
        ;;
    "test")
        test_workspace_assignments
        ;;
    "fix")
        apply_fix
        ;;
    "restart")
        restart_sketchybar
        ;;
    "menu"|*)
        echo "Usage: $0 [show|test|fix|restart]"
        echo ""
        echo "Commands:"
        echo "  show    - Display current monitor and workspace setup"
        echo "  test    - Test workspace switching and monitor assignments"
        echo "  fix     - Apply the workspace monitor fix"
        echo "  restart - Restart SketchyBar"
        echo ""
        echo "Recommended workflow:"
        echo "1. Run '$0 show' to see current setup"
        echo "2. Run '$0 test' to test current behavior"
        echo "3. Run '$0 fix' to apply the fix"
        echo "4. Run '$0 test' again to verify the fix works"
        ;;
esac
