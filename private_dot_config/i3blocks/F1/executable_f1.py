#!/usr/bin/env python3
"""
F1 i3block script for displaying F1 information.

Usage:
  python f1.py                      # Normal mode (only final output)
  python f1.py --debug              # Debug mode (verbose logging)
  python f1.py --raw-schedule       # Output raw schedule data from GPT
  python f1.py --raw-standings      # Output raw standings data from GPT
  python f1.py --raw                # Output both raw schedule and standings data
  python f1.py --refresh            # Force refresh of all data
  python f1.py --help               # Show help message
"""

import argparse
from loguru import logger
import os
from pathlib import Path
import sys

# Import configuration first
from config import setup_logging, CACHE_DIR, DB_PATH
import config  # Import the entire module for potential modification
from db import setup_database
from api import get_schedule_from_source, get_standings_from_source
from utils import get_race_type_emoji, get_country_flag, get_team_emoji


def main() -> None:
    """Main function that retrieves and formats F1 data for i3blocks."""
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description='F1 i3block script for displaying F1 information')
    parser.add_argument('--debug', action='store_true', help='Enable debug logging')
    parser.add_argument('--raw-schedule', action='store_true', help='Output raw schedule data from GPT')
    parser.add_argument('--raw-standings', action='store_true', help='Output raw standings data from GPT')
    parser.add_argument('--raw', action='store_true', help='Output both raw schedule and standings data')
    parser.add_argument('--refresh', action='store_true', help='Force refresh of all data')
    args = parser.parse_args()

    # Setup based on arguments
    debug_mode = args.debug
    raw_schedule = args.raw_schedule or args.raw
    raw_standings = args.raw_standings or args.raw
    force_refresh = args.refresh

    # Ensure script directory is writable for database
    script_dir = os.path.dirname(os.path.abspath(__file__))
    if not os.access(script_dir, os.W_OK):
        logger.warning(f"Script directory {script_dir} is not writable. Using cache directory for database.")
        # Fall back to cache directory if script directory is not writable
        config.DB_PATH = os.path.join(CACHE_DIR, "f1_data.db")

    # Ensure cache directory exists
    Path(CACHE_DIR).mkdir(parents=True, exist_ok=True)

    # Set up logging
    setup_logging(debug_mode)

    # Set up database
    setup_database()

    logger.debug("Starting F1 i3block script")
    if debug_mode:
        print("Running in DEBUG mode - check log file for details")

    try:
        # Handle raw output flags
        if raw_schedule or raw_standings:
            if raw_schedule:
                logger.debug("Getting schedule data for raw output")
                schedule_data = get_schedule_from_source(force_refresh)
                if "_raw_response" in schedule_data:
                    print("=== RAW SCHEDULE RESPONSE ===")
                    print(schedule_data["_raw_response"])
                    print("=============================")
                else:
                    print("No raw schedule response available")

            if raw_standings:
                logger.debug("Getting standings data for raw output")
                standings_data = get_standings_from_source(force_refresh)
                if "_raw_response" in standings_data:
                    print("=== RAW STANDINGS RESPONSE ===")
                    print(standings_data["_raw_response"])
                    print("==============================")
                else:
                    print("No raw standings response available")

            return

        # Normal operation - get data and format output
        schedule_data = get_schedule_from_source(force_refresh)
        if not schedule_data.get("races") and not force_refresh:
            logger.debug("No races found, trying with forced refresh")
            schedule_data = get_schedule_from_source(True)
        standings_data = get_standings_from_source(force_refresh)

        if "races" in schedule_data and schedule_data["races"]:
            next_race = schedule_data["races"][0]
            logger.debug(f"Next race: {next_race}")

            # Get race type emoji
            race_type = next_race.get("type", "Race")
            race_emoji = get_race_type_emoji(race_type)

            # Get country flag
            country = next_race.get("country", "")
            flag = get_country_flag(country)

            # Format the race information with countdown
            countdown = next_race.get("countdown", "Date TBA")
            race_name = next_race.get("name", "")

            # Create a nice formatted output
            session_text = f"{race_emoji} {flag} {race_name} {countdown}"
        else:
            logger.debug("No schedule data available")
            session_text = "🏎️ F1 schedule not available"

        if "drivers" in standings_data and standings_data["drivers"]:
            leader = standings_data["drivers"][0]
            logger.debug(f"Championship leader: {leader}")

            # Get team emoji and flag
            team_emoji = leader.get("team_emoji", "🏎️")
            flag = leader.get("flag", "")

            # Format the leader information
            driver_name = leader.get("driver", "Unknown")
            points = leader.get("points", "0")

            # Create a nice formatted output
            leader_text = f"👑 {flag} {driver_name} {team_emoji} {points}pts"
        else:
            logger.debug("No standings data available")
            leader_text = "👑 F1 standings not available"

        output = f"{session_text} | {leader_text}"
        logger.debug(f"Final output: {output}")
        print(output)
    except Exception as e:
        logger.debug(f"Unexpected error in main function: {e}", exc_info=True)
        print("F1 data unavailable | Error fetching data")


if __name__ == "__main__":
    main()
