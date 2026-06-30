#!/usr/bin/env python3
import json
import os
import sys
import argparse
import requests
from bs4 import BeautifulSoup
from datetime import datetime, timedelta
from langchain_openai import ChatOpenAI  # Use the new class from langchain_openai
from langchain.schema import HumanMessage, SystemMessage
from typing import Dict, Any, List, Optional


sys.path.insert(0, os.path.expanduser("~/.config/i3blocks"))
from secret_loader import load_secrets
load_secrets()
CHAT_API_KEY = os.environ["OPENAI_API_KEY"]
chat = ChatOpenAI(openai_api_key=CHAT_API_KEY, model_name="gpt-4-turbo")
SPACEX_URL = "https://spaceflightnow.com/launch-schedule/"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Extract SpaceX launch information.")
    # degbug flag
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Print debug information",
    )
    return parser.parse_args()


def fetch_html_content(url: str) -> str:
    try:
        response = requests.get(url)
        response.raise_for_status()
        return response.text
    except requests.RequestException as e:
        print(f"Error fetching data from {url}: {e}")
        return ""


def extract_main_content(html_content: str) -> str:
    soup = BeautifulSoup(html_content, "html.parser")
    main_content_div = soup.find("div", id="main-content")
    return (
        main_content_div.get_text(separator="\n", strip=True)
        if main_content_div
        else ""
    )


def extract_launch_data_with_langchain(content: str) -> str:
    current_year = datetime.now().year
    messages = [
        SystemMessage(
            content="You are an AI assistant that extracts structured data from HTML content."
        ),
        HumanMessage(
            content=f"Extract all SpaceX launch information (mission name, date_time, location) from the following content and provide it in JSON format, ensure that the date_time is able to be parsed directly into a python object and is the year isn't shown, assume it is {current_year}:\n\n{content}"
        ),
    ]
    try:
        response = chat(messages)
        return response.content.strip()
    except Exception as e:
        print(f"Error communicating with OpenAI API via LangChain: {e}")
        return ""


def pull_and_save_content():
    html_content = fetch_html_content(SPACEX_URL)
    if not html_content:
        print("Failed to fetch HTML content.")
        return

    main_content = extract_main_content(html_content)
    if not main_content:
        print("No relevant content found.")
        return

    extracted_info = extract_launch_data_with_langchain(main_content)
    print(
        "Extracted Information in JSON format:"
        if extracted_info
        else "Failed to extract information."
    )
    if extracted_info:
        ei = extracted_info.split("\n")
        # remove first and last element
        extracted_info = "\n".join(ei[1:-1])
        with open("spacex_launch_info.json", "w") as f:
            f.write(extracted_info)


def check_dates(content: List[Dict[str, str]]) -> bool:
    """
    Parse the dates in `date_time` and check if there are dates later than the current date.
    Date format is str: 2024-09-24T18:50:00Z (UTC).

    Args:
        content (List[Dict[str, str]]): A list of dictionaries with date strings in the 'date_time' key.

    Returns:
        bool: True if there are dates later than the current date, False otherwise.
    """
    for launch in content:
        date_time_str: str = launch["date_time"]
        # Parse the date_time string as UTC
        try:
            date_time = datetime.strptime(date_time_str, "%Y-%m-%dT%H:%M:%SZ")
        except ValueError:
            continue

        # Check if the parsed date is later than the current date
        if date_time > datetime.utcnow():
            return True

    return False


def check_content() -> bool:
    current_file_dir = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(current_file_dir, "spacex_launch_info.json"), "r") as f:
        content: List[Dict[str, str]] = json.load(f)
    return check_dates(content)


def get_closest_date(content: List[Dict[str, str]]) -> Optional[Dict[str, str]]:
    """
    Find and return the dictionary with the closest future date from the current date.
    Date format in the dictionary is str: 2024-09-24T18:50:00Z (UTC).

    Args:
        content (List[Dict[str, str]]): A list of dictionaries with date strings in the 'date_time' key.

    Returns:
        Optional[Dict[str, str]]: The dictionary with the closest future date, or None if no future dates are found.
    """
    closest_future_item: Optional[Dict[str, str]] = None
    closest_future_date: Optional[datetime] = None

    # Current time in UTC
    current_time = datetime.utcnow()

    for item in content:
        date_time_str: str = item["date_time"]
        if date_time_str == "TBD":
            continue

        # Check if the date_time_str is in the correct format
        try:
            # Parse the date_time string as UTC
            date_time = datetime.strptime(date_time_str, "%Y-%m-%dT%H:%M:%SZ")
        except ValueError:
            # Skip items with invalid date formats
            continue

        # Check if the date is in the future
        if date_time > current_time:
            # If this is the first future date or it is closer than the current closest future date
            if closest_future_date is None or date_time < closest_future_date:
                closest_future_date = date_time
                closest_future_item = item

    return closest_future_item


def make_pretty_print_with_countdown_from_today_to_date_time(
    closest_date: Dict[str, str]
) -> str:
    """
    Creates a formatted string with a countdown from today to the provided date and time.

    Args:
        closest_date (Dict[str, str]): A dictionary containing the closest future date in 'date_time' key.

    Returns:
        str: A formatted string with the countdown from today to the provided date and time.
    """
    if not closest_date or "date_time" not in closest_date:
        return "No upcoming date available"

    # Extract the date string
    date_time_str = closest_date["date_time"]

    try:
        # Parse the date_time string as UTC
        target_date = datetime.strptime(date_time_str, "%Y-%m-%dT%H:%M:%SZ")
    except ValueError:
        return "Invalid date format"

    # Get the current time in UTC
    current_time = datetime.utcnow()

    # Calculate the time difference
    time_diff = target_date - current_time

    if time_diff <= timedelta(0):
        return "The date has already passed"

    # Breakdown the time difference into days, hours, minutes, and seconds
    days = time_diff.days
    hours, remainder = divmod(time_diff.seconds, 3600)
    minutes, seconds = divmod(remainder, 60)

    # Construct the pretty print string
    countdown_str = (
        f"{closest_date['mission_name']} - {days}d:{hours}h:{minutes}m:{seconds}s"
    )

    return countdown_str


def main():
    if not check_content():
        pull_and_save_content()

    current_file_dir = os.path.dirname(os.path.abspath(__file__))
    with open(current_file_dir + "/spacex_launch_info.json", "r") as f:
        content: List[Dict[str, str]] = json.load(f)
    closest_date = get_closest_date(content)
    countdown_str = make_pretty_print_with_countdown_from_today_to_date_time(
        closest_date
    )
    print(countdown_str)


if __name__ == "__main__":
    main()
