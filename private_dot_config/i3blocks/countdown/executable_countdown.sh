#!/bin/bash

# Files to store the target date and emoji
DATE_FILE="$HOME/.config/i3blocks/countdown_date"
EMOJI_FILE="$HOME/.config/i3blocks/countdown_emoji"

# Default emoji if not set
DEFAULT_EMOJI="⏳"

# Function to calculate time difference
calculate_time_diff() {
    target_date=$(cat "$DATE_FILE" 2>/dev/null)
    
    if [ -z "$target_date" ]; then
        echo "Click to set date"
        return
    fi
    
    # Get current date in seconds since epoch
    current_date=$(date +%s)
    
    # Get target date in seconds since epoch
    target_seconds=$(date -d "$target_date" +%s 2>/dev/null)
    
    # Check if the date conversion was successful
    if [ $? -ne 0 ]; then
        echo "Invalid date"
        return
    fi
    
    # Calculate difference
    diff_seconds=$((target_seconds - current_date))
    
    if [ $diff_seconds -le 0 ]; then
        echo "Time's up!"
        return
    fi
    
    # Convert to days, hours, minutes, seconds
    days=$((diff_seconds / 86400))
    diff_seconds=$((diff_seconds % 86400))
    
    hours=$((diff_seconds / 3600))
    diff_seconds=$((diff_seconds % 3600))
    
    minutes=$((diff_seconds / 60))
    seconds=$((diff_seconds % 60))
    
    # Format the output
    if [ $days -gt 0 ]; then
        echo "$emoji ${days}d ${hours}h ${minutes}m ${seconds}s"
    elif [ $hours -gt 0 ]; then
        echo "$emoji ${hours}h ${minutes}m ${seconds}s"
    else
        echo "$emoji ${minutes}m ${seconds}s"
    fi
}

# Function to set emoji
set_emoji() {
    new_emoji=$(zenity --entry --title="Set Emoji" --text="Enter an emoji for your countdown:" --entry-text="$DEFAULT_EMOJI" 2>/dev/null)
    
    if [ -n "$new_emoji" ]; then
        echo "$new_emoji" > "$EMOJI_FILE"
    fi
}

# Function to set a new date
set_new_date() {
    new_date=$(zenity --calendar --title="Select Target Date" --date-format="%Y-%m-%d" 2>/dev/null)
    
    if [ -n "$new_date" ]; then
        # Ask for time
        new_time=$(zenity --entry --title="Enter Time (HH:MM)" --text="Enter time in 24-hour format (HH:MM):" --entry-text="23:59" 2>/dev/null)
        
        if [ -n "$new_time" ]; then
            # Validate time format using regex
            if [[ ! $new_time =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
                zenity --error --text="Invalid time format. Please use HH:MM (24-hour format)." 2>/dev/null
                return
            fi
            
            # Combine date and time
            echo "$new_date $new_time:00" > "$DATE_FILE"
        else
            # If no time selected, set to end of day
            echo "$new_date 23:59:59" > "$DATE_FILE"
        fi
    fi
}

# Handle click events
case $BLOCK_BUTTON in
    1) # Left click
        set_new_date
        ;;
    2) # Middle click
        set_emoji
        ;;
    3) # Right click
        # Reset/clear the date
        rm -f "$DATE_FILE"
        ;;
esac

# Make sure the directory exists
mkdir -p "$(dirname "$DATE_FILE")"

# Create default emoji file if it doesn't exist
if [ ! -f "$EMOJI_FILE" ]; then
    echo "$DEFAULT_EMOJI" > "$EMOJI_FILE"
fi

# Display the countdown
calculate_time_diff
