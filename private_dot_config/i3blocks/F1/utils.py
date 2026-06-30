"""Utility functions for the F1 i3block script."""

import re
import datetime
from typing import Optional, Union
from config import RACE_TYPE_EMOJIS, TEAM_EMOJIS, COUNTRY_FLAG_EMOJIS


def get_race_type_emoji(race_type: str) -> str:
    """Get an emoji for the race type."""
    race_type_lower = race_type.lower() if race_type else ""
    for key, emoji in RACE_TYPE_EMOJIS.items():
        if key in race_type_lower:
            return emoji
    return "🏎️"  # Default car emoji


def get_team_emoji(team: str) -> str:
    """Get an emoji for the team."""
    team_lower = team.lower() if team else ""
    for key, emoji in TEAM_EMOJIS.items():
        if key in team_lower:
            return emoji
    return "🏎️"  # Default car emoji


def get_country_flag(country: str) -> str:
    """Get a flag emoji for the country."""
    country_lower = country.lower() if country else ""
    for key, emoji in COUNTRY_FLAG_EMOJIS.items():
        if key in country_lower:
            return emoji
    return "🌍"  # Default world emoji


def format_countdown(time_delta: datetime.timedelta) -> str:
    """Format a timedelta into a human-readable countdown."""
    if time_delta.total_seconds() < 0:
        return "Completed"

    days = time_delta.days
    hours, remainder = divmod(time_delta.seconds, 3600)
    minutes, _ = divmod(remainder, 60)

    if days > 0:
        return f"T-{days}d {hours}h"
    elif hours > 0:
        return f"T-{hours}h {minutes}m"
    else:
        return f"T-{minutes}m"


def parse_date_time(date_str: str, time_str: str) -> Optional[datetime.datetime]:
    """
    Parse date and time strings into a datetime object.
    Handles various date formats commonly found in F1 schedules.
    """
    if not date_str:
        return None

    # Clean up the date string
    date_str = date_str.strip()
    time_str = time_str.strip() if time_str else "14:00"  # Default race time

    # Try to extract year if not present
    current_year = datetime.datetime.now().year
    if not any(str(year) in date_str for year in range(current_year - 1, current_year + 2)):
        date_str = f"{date_str} {current_year}"

    # Try various date formats
    date_formats = [
        "%d %b %Y",  # 25 Mar 2023
        "%d-%b-%Y",  # 25-Mar-2023
        "%d/%m/%Y",  # 25/03/2023
        "%Y-%m-%d",  # 2023-03-25
        "%b %d, %Y",  # Mar 25, 2023
        "%d %B %Y",  # 25 March 2023
    ]

    # Try to parse the date
    parsed_date = None
    for fmt in date_formats:
        try:
            parsed_date = datetime.datetime.strptime(date_str, fmt)
            break
        except ValueError:
            continue

    if not parsed_date:
        # Try more aggressive parsing for partial dates
        try:
            # Extract day, month, year using regex
            day_match = re.search(r'\b(\d{1,2})(st|nd|rd|th)?\b', date_str)
            month_match = re.search(r'\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\b', date_str, re.IGNORECASE)
            year_match = re.search(r'\b(20\d{2})\b', date_str)

            if day_match and month_match:
                day = day_match.group(1)
                month = month_match.group(1)
                year = year_match.group(1) if year_match else str(current_year)

                new_date_str = f"{day} {month} {year}"
                parsed_date = datetime.datetime.strptime(new_date_str, "%d %b %Y")
        except Exception:
            return None

    if not parsed_date:
        return None

    # Try to parse the time
    try:
        # Clean up time string and handle various formats
        time_str = time_str.replace(".", ":").strip()

        # Check if time has AM/PM
        if "AM" in time_str.upper() or "PM" in time_str.upper():
            time_obj = datetime.datetime.strptime(time_str, "%I:%M %p")
        else:
            # Try 24-hour format
            time_obj = datetime.datetime.strptime(time_str, "%H:%M")

        # Combine date and time
        return datetime.datetime.combine(
            parsed_date.date(),
            time_obj.time()
        )
    except ValueError:
        # If time parsing fails, use noon as default
        return datetime.datetime.combine(
            parsed_date.date(),
            datetime.time(14, 0)  # 2:00 PM, common F1 race time
        )
