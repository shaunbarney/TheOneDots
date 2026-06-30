"""Configuration settings for the F1 i3block script."""

import os
from loguru import logger
import sys
from pathlib import Path

# Get the directory where the script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(sys.argv[0]))

# Cache and database configuration
CACHE_DIR: str = os.path.expanduser("~/.cache/f1_i3block")
DB_PATH: str = os.path.join(SCRIPT_DIR, "f1_data.db")  # Store DB in script directory
SCHEDULE_CACHE: str = os.path.join(CACHE_DIR, "schedule_html.html")
STANDINGS_CACHE: str = os.path.join(CACHE_DIR, "standings_html.html")
CACHE_TIMEOUT: int = 1800  # 30 minutes for HTML cache
DB_REFRESH_INTERVAL: int = 86400  # 24 hours for DB refresh

# URLs
SKY_SPORTS_STANDINGS_URL = "https://www.skysports.com/f1/standings"
SKY_SPORTS_SCHEDULE_URL = "https://www.skysports.com/f1/schedule-results"

# OpenAI API key
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")

# Emoji mappings
RACE_TYPE_EMOJIS = {
    "race": "🏁",
    "grand prix": "🏁",
    "practice": "🏎️",
    "fp1": "🏎️",
    "fp2": "🏎️",
    "fp3": "🏎️",
    "qualifying": "⏱️",
    "sprint": "🚀",
    "sprint qualifying": "🚀",
    "sprint shootout": "🚀",
}

TEAM_EMOJIS = {
    "red bull": "🐂",
    "ferrari": "🐎",
    "mercedes": "⭐",
    "mclaren": "🧡",
    "aston martin": "💚",
    "alpine": "🔵",
    "williams": "🔷",
    "alphatauri": "⚪",
    "rb": "⚪",
    "haas": "⚫",
    "alfa romeo": "🔴",
    "sauber": "🔴",
}

COUNTRY_FLAG_EMOJIS = {
    "australia": "🇦🇺",
    "austria": "🇦🇹",
    "azerbaijan": "🇦🇿",
    "bahrain": "🇧🇭",
    "belgium": "🇧🇪",
    "brazil": "🇧🇷",
    "canada": "🇨🇦",
    "china": "🇨🇳",
    "france": "🇫🇷",
    "germany": "🇩🇪",
    "hungary": "🇭🇺",
    "italy": "🇮🇹",
    "japan": "🇯🇵",
    "mexico": "🇲🇽",
    "monaco": "🇲🇨",
    "netherlands": "🇳🇱",
    "portugal": "🇵🇹",
    "qatar": "🇶🇦",
    "saudi arabia": "🇸🇦",
    "singapore": "🇸🇬",
    "spain": "🇪🇸",
    "united states": "🇺🇸",
    "usa": "🇺🇸",
    "united kingdom": "🇬🇧",
    "uk": "🇬🇧",
    "great britain": "🇬🇧",
    "abu dhabi": "🇦🇪",
    "uae": "🇦🇪",
    "miami": "🇺🇸",
    "las vegas": "🇺🇸",
    "imola": "🇮🇹",
    "emilia romagna": "🇮🇹",
}


def setup_logging(debug_mode: bool) -> None:
    """Set up logging with loguru."""
    LOG_FILE = os.path.join(CACHE_DIR, "debug.log")
    logger.remove()  # Remove default handler
    logger.add(LOG_FILE, level="DEBUG" if debug_mode else "ERROR", rotation="1 MB")
    if debug_mode:
        logger.add(lambda msg: print(msg), level="DEBUG", colorize=True)
