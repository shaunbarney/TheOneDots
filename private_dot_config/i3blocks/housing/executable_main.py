#!/usr/bin/env python3

import os
import json
import requests
from datetime import datetime
from typing import Optional, Dict
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)

DATA_DIR = "./data"

def fetch_hpi_data(region: str, year: int, month: int) -> Optional[Dict]:
    """
    Fetches HPI data from the UK House Price Index API.

    Args:
        region (str): The region to fetch data for (e.g., "north-east").
        year (int): The year of the data.
        month (int): The month of the data.

    Returns:
        Optional[Dict]: Parsed JSON response from the API or None if an error occurred.
    """
    base_url = "http://landregistry.data.gov.uk/data/ukhpi/region"
    url = f"{base_url}/{region}/month/{year:04d}-{month:02d}.json"

    try:
        logging.info(f"Fetching data from URL: {url}")
        response = requests.get(url, headers={"Accept": "application/json"}, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to fetch data: {e}")
        return None
    except json.JSONDecodeError as e:
        logging.error(f"Error decoding JSON response: {e}")
        return None

def process_data(data: Dict) -> str:
    """
    Processes HPI data to calculate detached house price changes and format output.

    Args:
        data (Dict): Parsed JSON data from the API.

    Returns:
        str: Formatted string for i3blocks display.
    """
    if not data or "result" not in data or "primaryTopic" not in data["result"]:
        logging.warning("Invalid data structure or missing required fields.")
        return "Detached: N/A 🛑"

    primary_topic = data["result"].get("primaryTopic", {})

    if not isinstance(primary_topic, dict):
        logging.warning("Primary topic is not a valid dictionary.")
        return "Detached: N/A 🛑"

    avg_detached_price = primary_topic.get("averagePriceDetached", "N/A")
    perc_change_detached = primary_topic.get("percentageChangeDetached", "N/A")

    try:
        emoji = "📈" if float(perc_change_detached) > 0 else "📉"
        perc_change_str = f"{float(perc_change_detached):.2f}% {emoji}"
    except (ValueError, TypeError):
        logging.warning("Invalid percentage change format.")
        perc_change_str = "N/A 🛑"

    avg_price_str = f"£{avg_detached_price}" if avg_detached_price != "N/A" else "N/A 🛑"

    return f"Detached: {perc_change_str}, Avg: {avg_price_str}"

def save_data(data: Dict, region: str, year: int, month: int) -> None:
    """
    Saves the HPI data to a file.

    Args:
        data (Dict): Parsed JSON data from the API.
        region (str): The region of the data.
        year (int): The year of the data.
        month (int): The month of the data.
    """
    try:
        if not os.path.exists(DATA_DIR):
            os.makedirs(DATA_DIR)
        
        filename = f"{region}_{year}_{month:02d}.json"
        filepath = os.path.join(DATA_DIR, filename)
        
        with open(filepath, "w", encoding="utf-8") as file:
            json.dump(data, file, ensure_ascii=False, indent=4)

        logging.info(f"Data successfully saved to {filepath}")
    except (OSError, IOError) as e:
        logging.error(f"Failed to save data to file: {e}")

if __name__ == "__main__":
    # Configuration for the block
    region = "north-east"  # Change this to your desired region
    year = datetime.now().year
    month = datetime.now().month - 3  # Fetch last 3 months' data

    if month <= 0:
        month += 12
        year -= 1

    try:
        data = fetch_hpi_data(region, year, month)

        if data:
            save_data(data, region, year, month)
            output = process_data(data)
            print(output)  # Full text for i3blocks
            print("#00FF00")  # Colour for i3blocks (Green for success)
        else:
            print("HPI: N/A 🛑")
            print("#FF0000")  # Colour for i3blocks (Red for failure)
    except Exception as e:
        logging.critical(f"Unexpected error: {e}")
        print("HPI: N/A 🛑")
        print("#FF0000")
