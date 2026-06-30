import tkinter as tk
from tkinter import messagebox
from tkinter import ttk
import threading
import time
import json
import os
import ttkbootstrap as tb

SAVE_FILE = "saved_times.json"
DEFAULT_TIMES = ["00:05:00", "00:10:00", "00:15:00"]


class CountdownTimerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Enhanced Countdown Timer")
        self.root.geometry("400x250")
        self.style = tb.Style(theme="flatly")  # Better-looking theme

        # Time Input Variables
        self.time_var = tk.StringVar(value="00:00:00")
        self.saved_times = self.load_saved_times()

        # Frame for Time Input
        frame = ttk.Frame(self.root)
        frame.pack(pady=10)

        # Label and Entry for Time
        ttk.Label(frame, text="Enter time (HH:MM:SS):").grid(row=0, column=0, padx=5)
        self.time_entry = ttk.Entry(frame, textvariable=self.time_var, width=10)
        self.time_entry.grid(row=0, column=1, padx=5)

        # Buttons for Preset Times
        preset_frame = ttk.Frame(self.root)
        preset_frame.pack(pady=5)

        for i, preset_time in enumerate(DEFAULT_TIMES):
            ttk.Button(
                preset_frame,
                text=preset_time,
                command=lambda t=preset_time: self.set_time(t),
            ).grid(row=0, column=i, padx=5)

        # Start Button
        self.start_button = ttk.Button(
            self.root,
            text="Start Countdown",
            command=self.start_countdown,
            style="success.TButton",
        )
        self.start_button.pack(pady=10)

        # Display Label for Countdown
        self.display_label = ttk.Label(self.root, text="", font=("Helvetica", 20))
        self.display_label.pack(pady=5)

        # Dropdown for Last Used Times
        self.last_times_var = tk.StringVar(value="Select a saved time")
        self.last_times_dropdown = ttk.OptionMenu(
            self.root,
            self.last_times_var,
            *self.saved_times,
            command=self.set_time_from_dropdown,
        )
        self.last_times_dropdown.pack(pady=10)

    def set_time(self, time_str):
        """Set the time in the entry field."""
        self.time_var.set(time_str)

    def set_time_from_dropdown(self, value):
        """Set time from dropdown selection."""
        if value != "Select a saved time":
            self.set_time(value)

    def start_countdown(self):
        """Start the countdown."""
        try:
            h, m, s = map(int, self.time_var.get().split(":"))
            total_seconds = h * 3600 + m * 60 + s
            self.save_time(self.time_var.get())
            self.countdown(total_seconds)
        except ValueError:
            messagebox.showerror(
                "Invalid input", "Please enter time in HH:MM:SS format."
            )

    def countdown(self, total_seconds):
        """Countdown function running in a separate thread."""

        def run_countdown():
            while total_seconds >= 0:
                mins, secs = divmod(total_seconds, 60)
                hours, mins = divmod(mins, 60)
                time_str = f"{hours:02}:{mins:02}:{secs:02}"
                self.display_label.config(text=time_str)
                self.root.update()
                time.sleep(1)
                total_seconds -= 1
            messagebox.showinfo("Time's up!", "Countdown finished.")

        threading.Thread(target=run_countdown).start()

    def save_time(self, time_str):
        """Save time to the list of last used times."""
        if time_str not in self.saved_times:
            self.saved_times.insert(0, time_str)
            if len(self.saved_times) > 5:  # Keep only the last 5 times
                self.saved_times.pop()
            self.save_saved_times()

    def load_saved_times(self):
        """Load saved times from file."""
        if os.path.exists(SAVE_FILE):
            with open(SAVE_FILE, "r") as file:
                return json.load(file)
        return []

    def save_saved_times(self):
        """Save the list of saved times to a file."""
        with open(SAVE_FILE, "w") as file:
            json.dump(self.saved_times, file)


if __name__ == "__main__":
    root = tb.Window(themename="flatly")
    app = CountdownTimerApp(root)
    root.mainloop()
