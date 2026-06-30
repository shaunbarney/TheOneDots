#!/bin/bash

# Display the current date and time in the desired format
date "+%a, %d %b - %H:%M:%S"

# If clicked, open Google Calendar in the default browser
if [ "$BLOCK_BUTTON" -eq 1 ]; then
    xdg-open "https://calendar.google.com"
fi
