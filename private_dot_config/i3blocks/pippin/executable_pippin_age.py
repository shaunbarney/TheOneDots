#!/usr/bin/env python3

from datetime import datetime
from dateutil.relativedelta import relativedelta


def calculate_cat_age():
    # Pipping's birthday
    birth_date = datetime(2024, 9, 21)
    # Current date
    current_date = datetime.now()

    # Calculate the difference
    difference = relativedelta(current_date, birth_date)
    years = difference.years
    months = difference.months
    days = difference.days

    # Format the age string
    age_parts = []
    if years > 0:
        age_parts.append(f"{years}y")
    if months > 0 or years > 0:
        age_parts.append(f"{months}m")
    age_parts.append(f"{days}d")

    # Join with spaces and add the cat emoji
    return f"🐾 {' '.join(age_parts)}"


if __name__ == "__main__":
    print(calculate_cat_age())
