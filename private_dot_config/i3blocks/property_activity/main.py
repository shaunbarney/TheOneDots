#!/usr/bin/env python3
"""
Script to fetch and display the number of active property listings
in the Northeast of England using the Zoopla Property API.
"""

import requests
import sys

# Replace with your actual Zoopla API key
API_KEY = 'your_api_key_here'

# Define the area of interest
AREA = 'Northeast England'

# Zoopla API endpoint for property listings
API_URL = 'https://api.zoopla.co.uk/api/v1/property_listings.js'

def fetch_property_listings(api_key: str, area: str) -> int:
    """
    Fetch the number of active property listings for the specified area.

    Args:
        api_key (str): Zoopla API key.
        area (str): Area to search for property listings.

    Returns:
        int: Number of active property listings.
    """
    params = {
        'api_key': api_key,
        'area': area,
        'listing_status': 'sale',  # Options: 'sale' or 'rent'
        'page_size': 1,            # Minimal data to get total count
        'summarised': 'true'       # Get summary data
    }

    try:
        response = requests.get(API_URL, params=params)
        response.raise_for_status()
        data = response.json()
        return data.get('result_count', 0)
    except requests.RequestException as e:
        print(f"Error fetching data: {e}", file=sys.stderr)
        return -1

def main():
    """
    Main function to fetch and display the number of active property listings.
    """
    listings_count = fetch_property_listings(API_KEY, AREA)
    if listings_count >= 0:
        print(f"Active Listings: {listings_count}")
    else:
        print("Error fetching data")

if __name__ == '__main__':
    main()
