"""API interactions for the F1 i3block script."""

import os
import json
import datetime
import requests
from bs4 import BeautifulSoup
from loguru import logger
from typing import Dict, Any, List, Optional
from openai import OpenAI

from config import (
    OPENAI_API_KEY, CACHE_TIMEOUT, SCHEDULE_CACHE, STANDINGS_CACHE,
    CACHE_DIR, SKY_SPORTS_SCHEDULE_URL, SKY_SPORTS_STANDINGS_URL
)
from db import (
    should_refresh_data, save_races_to_db, save_drivers_to_db,
    get_races_from_db, get_drivers_from_db
)
from utils import parse_date_time, format_countdown, get_country_flag, get_team_emoji

# Initialize OpenAI client only when needed
_openai_client = None


def get_openai_client():
    """Get or initialize the OpenAI client."""
    global _openai_client
    if _openai_client is None:
        _openai_client = OpenAI(api_key=OPENAI_API_KEY)
        logger.debug("OpenAI client initialized")
    return _openai_client


def get_cached_html(cache_file: str, timeout: int = CACHE_TIMEOUT) -> Optional[str]:
    """Retrieve cached HTML if it exists and is fresh."""
    if os.path.exists(cache_file):
        file_age = datetime.datetime.now().timestamp() - os.path.getmtime(cache_file)
        if file_age < timeout:
            try:
                with open(cache_file, "r", encoding="utf-8") as f:
                    html = f.read()
                    logger.debug(f"Using cached HTML from {cache_file} (age: {file_age:.1f}s)")
                    return html
            except Exception as e:
                logger.debug(f"Error reading cache '{cache_file}': {e}")
    logger.debug(f"No valid cache found for {cache_file}")
    return None


def save_html_to_cache(cache_file: str, html: str) -> None:
    """Save HTML content to a cache file."""
    try:
        with open(cache_file, "w", encoding="utf-8") as f:
            f.write(html)
        logger.debug(f"Saved HTML to cache: {cache_file} ({len(html)} bytes)")
    except Exception as e:
        logger.debug(f"Error writing cache '{cache_file}': {e}")


def process_html_with_chatgpt(extracted_html: str, extraction_type: str) -> Dict[str, Any]:
    """
    Send the extracted HTML snippet to ChatGPT with a prompt to extract the required information
    and return it in JSON format based on the given schema.
    """
    logger.debug(f"Processing {extraction_type} HTML with ChatGPT")

    # Log a sample of the HTML (first 200 chars)
    html_sample = extracted_html[:200] + "..." if len(extracted_html) > 200 else extracted_html
    logger.debug(f"HTML sample: {html_sample}")

    if extraction_type == "schedule":
        schema = {
            "races": [
                {
                    "name": "string",
                    "date": "string",
                    "circuit": "string",
                    "time": "string",
                    "country": "string",
                    "type": "string"
                }
            ]
        }
        prompt = (
            f"Extract the F1 race schedule from the following HTML snippet. "
            f"Return the result as JSON using the schema below. For each race, include the country "
            f"and the type (e.g., 'Race', 'Practice', 'Qualifying', 'Sprint') if available:\n"
            f"{json.dumps(schema, indent=2)}\n\n"
            f"HTML Snippet:\n{extracted_html}"
        )
    elif extraction_type == "standings":
        schema = {
            "drivers": [
                {
                    "position": "string",
                    "driver": "string",
                    "team": "string",
                    "points": "string",
                    "nationality": "string"
                }
            ]
        }
        prompt = (
            f"Extract the F1 driver standings from the following HTML snippet. "
            f"Return the result as JSON using the schema below. Include the driver's nationality "
            f"if available:\n"
            f"{json.dumps(schema, indent=2)}\n\n"
            f"HTML Snippet:\n{extracted_html}"
        )
    else:
        logger.debug(f"Unknown extraction_type: {extraction_type}")
        raise ValueError("Unknown extraction_type. Must be 'schedule' or 'standings'.")

    logger.debug(f"Prompt to ChatGPT: {prompt[:200]}...")

    try:
        logger.debug("Sending request to OpenAI API")
        response = get_openai_client().chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            temperature=0,
        )
        logger.debug(f"Received response from OpenAI API")

        # Get the content from the response
        content = response.choices[0].message.content.strip()
        logger.debug(f"Raw content from ChatGPT: {content[:200]}...")

        # Store the raw response
        result = {"_raw_response": content}

        # Try to parse the JSON response
        try:
            # Find JSON in the response (it might be wrapped in markdown code blocks)
            json_match = content
            if "```json" in content:
                json_match = content.split("```json")[1].split("```")[0].strip()
            elif "```" in content:
                json_match = content.split("```")[1].strip()

            parsed_data = json.loads(json_match)
            result.update(parsed_data)
            logger.debug(f"Successfully parsed JSON response")
        except json.JSONDecodeError as e:
            logger.debug(f"Error parsing JSON response: {e}")
            # Try to extract JSON using regex as a fallback
            import re
            json_pattern = r'\{.*\}'
            match = re.search(json_pattern, content, re.DOTALL)
            if match:
                try:
                    parsed_data = json.loads(match.group(0))
                    result.update(parsed_data)
                    logger.debug(f"Successfully parsed JSON using regex")
                except json.JSONDecodeError:
                    logger.debug(f"Failed to parse JSON using regex")
                    if extraction_type == "schedule":
                        result["races"] = []
                    elif extraction_type == "standings":
                        result["drivers"] = []
            else:
                logger.debug(f"No JSON found in response")
                if extraction_type == "schedule":
                    result["races"] = []
                elif extraction_type == "standings":
                    result["drivers"] = []

        return result
    except Exception as e:
        logger.debug(f"Error calling OpenAI API: {e}")
        return {
            "error": f"Error calling OpenAI API: {str(e)}",
            "_raw_response": f"Error: {str(e)}",
            "races" if extraction_type == "schedule" else "drivers": []
        }


def get_schedule_from_source(force_refresh: bool = False) -> Dict[str, Any]:
    """
    Download the HTML from the Sky Sports F1 schedule page,
    extract the relevant HTML elements containing race information,
    then use ChatGPT to extract race schedule details in JSON.
    """
    # Check if we should use cached data from the database
    if not should_refresh_data("schedule", force_refresh):
        races = get_races_from_db()
        if races:
            logger.debug(f"Using {len(races)} races from database")
            return {"races": races, "_from_db": True}

    # Use Sky Sports URL
    url = SKY_SPORTS_SCHEDULE_URL
    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"}
    logger.debug(f"Getting F1 schedule from {url}")

    # Force refresh the HTML cache to get fresh data
    html = None if force_refresh else get_cached_html(SCHEDULE_CACHE)
    if html is None:
        try:
            logger.debug("Downloading fresh schedule HTML")
            r = requests.get(url, headers=headers, timeout=10)
            r.raise_for_status()
            html = r.text
            logger.debug(f"Downloaded {len(html)} bytes of HTML")
            save_html_to_cache(SCHEDULE_CACHE, html)
        except Exception as e:
            logger.debug(f"Error downloading schedule: {e}")
            return {
                "error": f"Error downloading schedule: {str(e)}",
                "_raw_response": f"Error downloading schedule: {str(e)}"
            }

    try:
        soup = BeautifulSoup(html, "html.parser")
        logger.debug("Parsing HTML with BeautifulSoup")

        # First try to find the specific div containing the schedule
        schedule_div = soup.find("div", class_="grid__col site-layout-secondary__col1")
        if schedule_div:
            logger.debug("Found schedule div with class 'grid__col site-layout-secondary__col1'")

            # Extract a smaller portion of HTML to avoid context length issues
            extracted_html = str(schedule_div)
            logger.debug(f"Extracted {len(extracted_html)} bytes of HTML from schedule div")

            # Save the extracted HTML for debugging
            debug_html_path = os.path.join(CACHE_DIR, "extracted_schedule.html")
            with open(debug_html_path, "w", encoding="utf-8") as f:
                f.write(extracted_html)
            logger.debug(f"Saved extracted HTML to {debug_html_path} for debugging")

            # Try to manually extract race information
            races = []

            # Look for race elements within this div
            race_elements = schedule_div.find_all(['a', 'div', 'tr'], class_=lambda c: c and
                                                  ('race' in str(c).lower() or 'event' in str(c).lower()))

            if race_elements:
                logger.debug(f"Found {len(race_elements)} race elements within the schedule div")

                for race_elem in race_elements:
                    try:
                        race_data = {}

                        # Extract race name
                        race_name_elem = race_elem.find(["h2", "h3", "h4", "span", "div"],
                                                        class_=lambda c: c and ('name' in str(c).lower() or 'title' in str(c).lower()))
                        if race_name_elem:
                            race_data["name"] = race_name_elem.text.strip()
                            # Country is usually the same as the race name for most races
                            country = race_name_elem.text.strip()
                            if "Grand Prix" in country:
                                country = country.split("Grand Prix")[0].strip()
                            race_data["country"] = country

                        # Extract race date
                        race_date_elem = race_elem.find(["p", "span", "div"],
                                                        class_=lambda c: c and ('date' in str(c).lower() or 'time' in str(c).lower()))
                        if race_date_elem:
                            race_data["date"] = race_date_elem.text.strip()

                        # Extract circuit name
                        circuit_elem = race_elem.find(["p", "span", "div"],
                                                      class_=lambda c: c and ('circuit' in str(c).lower() or 'track' in str(c).lower()))
                        if circuit_elem:
                            race_data["circuit"] = circuit_elem.text.strip()

                        # Default type to "Race" if not found
                        race_data["type"] = "Race"

                        # Only add if we have at least a name and date
                        if "name" in race_data and "date" in race_data:
                            races.append(race_data)
                            logger.debug(f"Extracted race: {race_data['name']} on {race_data['date']}")
                    except Exception as e:
                        logger.debug(f"Error extracting race data: {e}")

            # If no races found with specific elements, try to find any mentions of Grand Prix
            if not races:
                logger.debug("No races found with specific elements, looking for Grand Prix mentions")
                for elem in schedule_div.find_all(["h2", "h3", "h4", "p", "div", "span"]):
                    if "Grand Prix" in elem.text or "GP" in elem.text:
                        # Try to find a date nearby
                        date_elem = None
                        next_elem = elem.find_next()
                        for i in range(3):  # Check the next 3 elements
                            if next_elem and any(month in next_elem.text for month in
                                                 ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]):
                                date_elem = next_elem
                                break
                            if next_elem:
                                next_elem = next_elem.find_next()

                        race_data = {
                            "name": elem.text.strip(),
                            "country": elem.text.strip().split("Grand Prix")[0].strip(),
                            "date": date_elem.text.strip() if date_elem else "",
                            "circuit": "",
                            "type": "Race"
                        }

                        if race_data["date"]:
                            races.append(race_data)
                            logger.debug(f"Extracted race from Grand Prix mention: {race_data['name']} on {race_data['date']}")
        else:
            # Fall back to previous extraction methods
            logger.debug("Could not find div with class 'grid__col site-layout-secondary__col1', using fallback methods")

            # Try to find race elements with specific classes
            race_elements = soup.find_all('a', class_="f1-races__race")
            if race_elements:
                logger.debug(f"Found {len(race_elements)} individual race elements")

                for race_elem in race_elements:
                    try:
                        race_data = {}

                        # Extract race name
                        race_name_elem = race_elem.find("h2", class_="f1-races__race-name")
                        if race_name_elem:
                            race_data["name"] = race_name_elem.text.strip()
                            # Country is usually the same as the race name for most races
                            race_data["country"] = race_name_elem.text.strip()

                        # Extract race date
                        race_date_elem = race_elem.find("p", class_="f1-races__date")
                        if race_date_elem:
                            race_data["date"] = race_date_elem.text.strip()

                        # Extract circuit name
                        circuit_elem = race_elem.find("p", class_="f1-races__circuit")
                        if circuit_elem:
                            race_data["circuit"] = circuit_elem.text.strip()

                        # Default type to "Race" if not found
                        race_data["type"] = "Race"

                        # Only add if we have at least a name and date
                        if "name" in race_data and "date" in race_data:
                            races.append(race_data)
                            logger.debug(f"Extracted race: {race_data['name']} on {race_data['date']}")
                    except Exception as e:
                        logger.debug(f"Error extracting race data: {e}")

            # If we couldn't extract races using the specific classes, try a more general approach
            if not races:
                logger.debug("No races found with specific classes, trying general approach")

                # Look for any elements that might contain race information
                potential_races = []

                # Look for elements with "Grand Prix" in the text
                for elem in soup.find_all(["h1", "h2", "h3", "h4", "p", "div"]):
                    if "Grand Prix" in elem.text or "GP" in elem.text:
                        # Try to find a date nearby
                        date_elem = None
                        next_elem = elem.find_next()
                        for i in range(3):  # Check the next 3 elements
                            if next_elem and any(month in next_elem.text for month in
                                                 ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]):
                                date_elem = next_elem
                                break
                            if next_elem:
                                next_elem = next_elem.find_next()

                        race_data = {
                            "name": elem.text.strip(),
                            "country": elem.text.strip().split("Grand Prix")[0].strip(),
                            "date": date_elem.text.strip() if date_elem else "",
                            "circuit": "",
                            "type": "Race"
                        }

                        if race_data["date"]:
                            potential_races.append(race_data)

                if potential_races:
                    races = potential_races
                    logger.debug(f"Extracted {len(races)} potential races using general approach")

        logger.debug(f"Total races extracted: {len(races)}")

        # Process race dates and add countdown information
        now = datetime.datetime.now()
        future_races = []
        past_races = []

        for race in races:
            # Try to parse the date and time
            race_datetime = parse_date_time(race.get("date", ""), race.get("time", ""))

            if race_datetime:
                # Calculate time until race
                time_until = race_datetime - now
                race["countdown"] = format_countdown(time_until)
                race["timestamp"] = race_datetime.timestamp()
                race["is_future"] = time_until.total_seconds() > 0

                # Add to appropriate list
                if race["is_future"]:
                    future_races.append(race)
                else:
                    past_races.append(race)
            else:
                # If we can't parse the date, assume it's in the future
                race["countdown"] = "Date TBA"
                race["timestamp"] = float('inf')  # Far future
                race["is_future"] = True
                future_races.append(race)

        logger.debug(f"Found {len(future_races)} future races and {len(past_races)} past races")

        # Sort future races by timestamp (closest first)
        if future_races:
            future_races.sort(key=lambda r: r.get("timestamp", float('inf')))
            result = {"races": future_races}
            logger.debug(f"Next race: {future_races[0]['name']} on {future_races[0].get('date', 'unknown date')}")
        else:
            # If no future races, use past races sorted by most recent
            past_races.sort(key=lambda r: r.get("timestamp", 0), reverse=True)
            result = {"races": past_races}
            if past_races:
                logger.debug(f"No future races found. Most recent race: {past_races[0]['name']}")
            else:
                logger.debug("No races found at all")
                result = {"races": []}

        # Save races to database
        save_races_to_db(result["races"])

        return result
    except Exception as e:
        logger.debug(f"Error processing schedule HTML: {e}", exc_info=True)
        return {
            "error": f"Error processing schedule HTML: {str(e)}",
            "_raw_response": f"Error processing schedule HTML: {str(e)}"
        }


def get_standings_from_source(force_refresh: bool = False) -> Dict[str, Any]:
    """
    Download the HTML from the Sky Sports F1 standings page,
    extract the relevant HTML elements containing driver standings,
    then use ChatGPT to extract standings details in JSON.
    """
    # Check if we should use cached data from the database
    if not should_refresh_data("standings", force_refresh):
        drivers = get_drivers_from_db()
        if drivers:
            logger.debug(f"Using {len(drivers)} drivers from database")
            return {"drivers": drivers, "_from_db": True}

    # Use Sky Sports URL
    url = SKY_SPORTS_STANDINGS_URL
    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"}
    logger.debug(f"Getting F1 standings from {url}")

    html = get_cached_html(STANDINGS_CACHE)
    if html is None:
        try:
            logger.debug("Downloading fresh standings HTML")
            r = requests.get(url, headers=headers, timeout=10)
            r.raise_for_status()
            html = r.text
            logger.debug(f"Downloaded {len(html)} bytes of HTML")
            save_html_to_cache(STANDINGS_CACHE, html)
        except Exception as e:
            logger.debug(f"Error downloading standings: {e}")
            return {
                "error": f"Error downloading standings: {str(e)}",
                "_raw_response": f"Error downloading standings: {str(e)}"
            }

    try:
        soup = BeautifulSoup(html, "html.parser")
        logger.debug("Parsing HTML with BeautifulSoup")

        # For Sky Sports, look for the standings table
        standings_table = soup.find("table")

        if not standings_table:
            logger.debug("No table found for driver standings")

            # Try alternative selectors
            logger.debug("Trying alternative HTML selectors")
            standings_div = soup.find("div", class_=lambda c: c and ("standing" in c.lower() or "driver" in c.lower()))
            if standings_div:
                logger.debug(f"Found div with standings/driver class")
                standings_table = standings_div

        if not standings_table:
            logger.debug("Could not find any suitable HTML element for driver standings")
            # Log a sample of the HTML to help debug
            logger.debug(f"HTML sample: {html[:500]}...")
            return {
                "error": "Could not find driver standings data in HTML",
                "_raw_response": "Error: Could not find driver standings data in HTML"
            }

        extracted_html = str(standings_table)
        logger.debug(f"Extracted {len(extracted_html)} bytes of HTML for driver standings")

        result = process_html_with_chatgpt(extracted_html, "standings")
        drivers = result.get("drivers", [])
        logger.debug(f"Extracted {len(drivers)} drivers from standings")

        # Add team emojis to drivers
        for driver in drivers:
            team = driver.get("team", "")
            driver["team_emoji"] = get_team_emoji(team)

            # Add nationality flag if available
            nationality = driver.get("nationality", "")
            if nationality:
                driver["flag"] = get_country_flag(nationality)

        # Save drivers to database
        save_drivers_to_db(drivers)

        # Ensure the raw response is included
        if "_raw_response" not in result:
            result["_raw_response"] = "Raw response not available"

        return result
    except Exception as e:
        logger.debug(f"Error processing standings HTML: {e}")
        return {
            "error": f"Error processing standings HTML: {str(e)}",
            "_raw_response": f"Error processing standings HTML: {str(e)}"
        }
