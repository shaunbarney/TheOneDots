#!/usr/bin/env python3
import os
import json
import pandas as pd
import plotly.express as px


def load_data(data_folder: str) -> pd.DataFrame:
    """Load JSON files from the specified folder into a pandas DataFrame."""
    data_list = []
    for file_name in sorted(os.listdir(data_folder)):
        if file_name.endswith(".json"):
            file_path = os.path.join(data_folder, file_name)
            with open(file_path, "r") as f:
                data = json.load(f)
                primary_topic = data.get("result", {}).get("primaryTopic", {})
                ref_month = primary_topic.get("refMonth", "Unknown")
                row = {
                    "ref_month": ref_month,
                    "average_price": primary_topic.get("averagePrice", None),
                    "average_price_cash": primary_topic.get("averagePriceCash", None),
                    "average_price_detached": primary_topic.get(
                        "averagePriceDetached", None
                    ),
                    "average_price_first_time_buyer": primary_topic.get(
                        "averagePriceFirstTimeBuyer", None
                    ),
                    "percentage_annual_change": primary_topic.get(
                        "percentageAnnualChange", None
                    ),
                }
                data_list.append(row)
    return pd.DataFrame(data_list)


def create_plot(df: pd.DataFrame) -> None:
    """Create an interactive plot using Plotly."""
    # Convert ref_month to datetime for better plotting
    df["ref_month"] = pd.to_datetime(df["ref_month"])
    df = df.sort_values("ref_month")

    # Plot multiple statistics over time
    fig = px.line(
        df.melt(id_vars=["ref_month"], var_name="statistic", value_name="value"),
        x="ref_month",
        y="value",
        color="statistic",
        title="Housing Statistics Over Time",
        labels={
            "ref_month": "Reference Month",
            "value": "Value",
            "statistic": "Statistic",
        },
    )

    fig.update_layout(
        xaxis_title="Time",
        yaxis_title="Values",
        legend_title="Statistic",
        hovermode="x unified",
        template="plotly_dark",  # Optionally use a modern dark template
    )

    fig.show()


def main():
    """Main function to load data and create the plot."""
    data_folder = "./data"
    if not os.path.exists(data_folder):
        print(f"Data folder '{data_folder}' does not exist!")
        return

    data_df = load_data(data_folder)
    if data_df.empty:
        print("No data files found in the specified folder!")
        return

    create_plot(data_df)


if __name__ == "__main__":
    main()
