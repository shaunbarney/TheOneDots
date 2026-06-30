"""Database operations for the F1 i3block script."""

import sqlite3
import datetime
from typing import List, Dict, Any, Optional
import json

from loguru import logger
from config import DB_PATH, DB_REFRESH_INTERVAL
from utils import format_countdown, get_team_emoji, get_country_flag


def setup_database() -> None:
    """Set up the SQLite database with the necessary tables."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Create races table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS races (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        date TEXT,
        time TEXT,
        circuit TEXT,
        country TEXT,
        type TEXT,
        timestamp REAL,
        last_updated REAL
    )
    ''')

    # Create drivers table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS drivers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        position INTEGER,
        driver TEXT,
        team TEXT,
        points TEXT,
        nationality TEXT,
        last_updated REAL
    )
    ''')

    # Create metadata table for tracking last refresh
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS metadata (
        key TEXT PRIMARY KEY,
        value TEXT,
        timestamp REAL
    )
    ''')

    conn.commit()
    conn.close()
    logger.debug("Database setup complete")


def should_refresh_data(data_type: str, force_refresh: bool = False) -> bool:
    """Check if data should be refreshed based on last update time."""
    if force_refresh:
        logger.debug(f"Forced refresh requested for {data_type}")
        return True

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Check when data was last updated
    cursor.execute(
        "SELECT timestamp FROM metadata WHERE key = ?",
        (f"last_{data_type}_update",)
    )
    row = cursor.fetchone()

    if not row:
        logger.debug(f"No previous {data_type} data found, refresh needed")
        conn.close()
        return True

    last_update = row[0]
    current_time = datetime.datetime.now().timestamp()
    time_since_update = current_time - last_update

    # If it's schedule data, also check if the next race has passed
    if data_type == "schedule":
        cursor.execute(
            "SELECT MIN(timestamp) FROM races WHERE timestamp > ?",
            (current_time,)
        )
        next_race_row = cursor.fetchone()

        if next_race_row and next_race_row[0]:
            next_race_time = next_race_row[0]
            # If the next race was in the future but is now in the past, refresh
            if next_race_time < current_time:
                logger.debug("Next race has passed, refresh needed")
                conn.close()
                return True

    conn.close()

    # Check if we've passed the refresh interval
    needs_refresh = time_since_update > DB_REFRESH_INTERVAL
    logger.debug(f"{data_type} data is {time_since_update:.1f}s old, refresh needed: {needs_refresh}")
    return needs_refresh


def save_races_to_db(races: List[Dict[str, Any]]) -> None:
    """Save race data to the database."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Clear existing races
    cursor.execute("DELETE FROM races")

    # Insert new races
    current_time = datetime.datetime.now().timestamp()
    for race in races:
        cursor.execute('''
        INSERT INTO races (name, date, time, circuit, country, type, timestamp, last_updated)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            race.get("name", ""),
            race.get("date", ""),
            race.get("time", ""),
            race.get("circuit", ""),
            race.get("country", ""),
            race.get("type", ""),
            race.get("timestamp", float('inf')),
            current_time
        ))

    # Update metadata
    cursor.execute('''
    INSERT OR REPLACE INTO metadata (key, value, timestamp)
    VALUES (?, ?, ?)
    ''', ("last_schedule_update", "success", current_time))

    conn.commit()
    conn.close()
    logger.debug(f"Saved {len(races)} races to database")


def save_drivers_to_db(drivers: List[Dict[str, Any]]) -> None:
    """Save driver data to the database."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Clear existing drivers
    cursor.execute("DELETE FROM drivers")

    # Insert new drivers
    current_time = datetime.datetime.now().timestamp()
    for driver in drivers:
        try:
            position = int(driver.get("position", "0"))
        except ValueError:
            position = 0

        cursor.execute('''
        INSERT INTO drivers (position, driver, team, points, nationality, last_updated)
        VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            position,
            driver.get("driver", ""),
            driver.get("team", ""),
            driver.get("points", ""),
            driver.get("nationality", ""),
            current_time
        ))

    # Update metadata
    cursor.execute('''
    INSERT OR REPLACE INTO metadata (key, value, timestamp)
    VALUES (?, ?, ?)
    ''', ("last_standings_update", "success", current_time))

    conn.commit()
    conn.close()
    logger.debug(f"Saved {len(drivers)} drivers to database")


def get_races_from_db() -> List[Dict[str, Any]]:
    """Get race data from the database."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row  # This enables column access by name
    cursor = conn.cursor()

    # Get all races ordered by timestamp
    cursor.execute("SELECT * FROM races ORDER BY timestamp ASC")
    rows = cursor.fetchall()

    races = []
    now = datetime.datetime.now().timestamp()

    for row in rows:
        race = dict(row)

        # Calculate countdown
        if race["timestamp"] != float('inf'):
            time_until = datetime.timedelta(seconds=race["timestamp"] - now)
            race["countdown"] = format_countdown(time_until)
            race["is_future"] = race["timestamp"] > now
        else:
            race["countdown"] = "Date TBA"
            race["is_future"] = True

        races.append(race)

    conn.close()

    # Separate future and past races
    future_races = [r for r in races if r.get("is_future", True)]
    past_races = [r for r in races if not r.get("is_future", True)]

    # Return future races first, then past races
    return future_races + past_races


def get_drivers_from_db() -> List[Dict[str, Any]]:
    """Get driver data from the database."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row  # This enables column access by name
    cursor = conn.cursor()

    # Get all drivers ordered by position
    cursor.execute("SELECT * FROM drivers ORDER BY position ASC")
    rows = cursor.fetchall()

    drivers = []
    for row in rows:
        driver = dict(row)

        # Add emojis
        driver["team_emoji"] = get_team_emoji(driver.get("team", ""))
        driver["flag"] = get_country_flag(driver.get("nationality", ""))

        drivers.append(driver)

    conn.close()
    return drivers
