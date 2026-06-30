#!/usr/bin/env python3
import os
import sys
import requests
import datetime
import pandas as pd
from pathlib import Path

sys.path.insert(0, os.path.expanduser("~/.config/i3blocks"))
from secret_loader import load_secrets
load_secrets()

# Define the API endpoint and your API key
api_url = "https://api.api-ninjas.com/v1/interestrate?country=United Kingdom"
api_key = os.environ["API_NINJAS_KEY"]

# File to store interest rate data
LOCATION_OF_CURRENT_FILE = Path("/home/shaun/.config/i3blocks/interest_rates")
file_path = LOCATION_OF_CURRENT_FILE / Path("interest_rates.csv")

# Function to fetch the latest interest rate
def fetch_interest_rate():
    response = requests.get(api_url, headers={"X-Api-Key": api_key})
    if response.status_code == 200:
        try:
            data = response.json()
            rate = data["central_bank_rates"][0]
            return float(rate["rate_pct"]), rate["last_updated"]
        except (ValueError, KeyError) as e:
            print(f"Error: Could not parse JSON. Response was: {response.text}")
            return None, None
    else:
        print(f"Error: {response.status_code} - {response.text}")
        return None, None


# Function to load interest rates from file using pandas
def load_interest_rates():
    if file_path.exists():
        return pd.read_csv(file_path, parse_dates=["Date"])
    else:
        # Return an empty DataFrame if the file does not exist
        return pd.DataFrame(columns=["Date", "Rate"])


# Function to save interest rates to file using pandas
def save_interest_rates(df):
    df.to_csv(file_path, index=False)


# Function to log interest rate to DataFrame
def log_interest_rate(df, rate, date):
    # Check if today's date is already in the DataFrame
    if date not in df["Date"].values:
        new_entry = pd.DataFrame({"Date": [date], "Rate": [rate]})
        df = pd.concat([df, new_entry], ignore_index=True)
    return df


# Function to display the most recent interest rate change
def display_interest_rate_change(df):
    if df.empty or len(df) < 2:
        print("No changes in interest rates recorded.")
        return

    # Sort by date to ensure chronological order
    df = df.sort_values(by="Date")

    # Get the latest rate
    latest_rate = df["Rate"].iloc[-1]

    # Find the most recent date where the rate changed
    for i in range(len(df) - 2, -1, -1):  # Start from the second-to-last row
        if df["Rate"].iloc[i] != latest_rate:
            previous_rate = df["Rate"].iloc[i]
            change_date = df["Date"].iloc[i + 1]  # The date when the rate changed
            change = latest_rate - previous_rate
            days_since_change = (pd.Timestamp(datetime.date.today()) - change_date).days
            emoji = "🔺" if change > 0 else "🔻"
            print(
                f"📊 Current Rate: {latest_rate}% ({emoji} {abs(change):.2f}% on {change_date.date()}, {days_since_change} days ago)"
            )
            return

    # If no previous change is found
    print("No previous rate change found.")


# Main function to handle daily fetching and logging
def main():
    today = pd.Timestamp(datetime.date.today())

    # Load existing interest rates
    df = load_interest_rates()

    # Fetch the latest rate and ensure it is logged only once per day
    rate, _ = fetch_interest_rate()

    if rate is not None:
        # Log new interest rate to DataFrame only if today's date is not present
        df = log_interest_rate(df, rate, today)
        save_interest_rates(df)

    # Display the latest interest rate change
    display_interest_rate_change(df)


if __name__ == "__main__":
    main()
