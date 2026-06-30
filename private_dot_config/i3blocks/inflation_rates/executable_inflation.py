#!/usr/bin/env python3
import os
import sys
import requests
import datetime

sys.path.insert(0, os.path.expanduser("~/.config/i3blocks"))
from secret_loader import load_secrets
load_secrets()

# Define the API endpoint and your API key
api_url = "https://api.api-ninjas.com/v1/inflation?country=United Kingdom"
api_key = os.environ["API_NINJAS_KEY"]

# File to store inflation data
file_path = "inflation_data.txt"

# Function to fetch the latest inflation rate
def fetch_inflation_rate():
    response = requests.get(api_url, headers={"X-Api-Key": api_key})
    if response.status_code == 200:
        try:
            data = response.json()
            inflation = data["inflation_rates"][0]
            return float(inflation["rate_pct"]), inflation["last_updated"]
        except ValueError:
            print("Error: Could not parse JSON. Response was:", response.text)
            return None, None
    else:
        print("Error:", response.status_code, response.text)
        return None, None


# Function to log inflation rate to file
def log_inflation_rate(rate, date):
    with open(file_path, "a") as file:
        file.write(f"{date},{rate}\n")


# Function to calculate and display the change in inflation rate
def display_inflation_rate():
    try:
        with open(file_path, "r") as file:
            lines = file.readlines()

        # Show 0 change if there are less than 2 entries
        if len(lines) < 2:
            last_rate = float(lines[-1].split(",")[1].strip()) if lines else 0.0
            print(f"📉 {last_rate}% (Change: 0.00)")
            return

        # Get the last two days of inflation rates
        last_rate = float(lines[-1].split(",")[1].strip())
        previous_rate = float(lines[-2].split(",")[1].strip())

        # Determine the change and display appropriately
        change = last_rate - previous_rate
        emoji = (
            "🔺" if change > 0 else "🔻"
        )  # Up arrow for increase, down arrow for decrease
        print(f"📉 {last_rate}% ({'+' if change > 0 else ''}{change:.2f}) {emoji}")
    except FileNotFoundError:
        print("Data file not found. Logging today's rate.")
        return


# Main function to handle daily fetching and logging
def main():
    today = datetime.date.today()
    rate, last_updated = fetch_inflation_rate()

    if rate is not None:
        log_inflation_rate(rate, today)
        display_inflation_rate()


if __name__ == "__main__":
    main()
