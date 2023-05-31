#!/usr/bin/env python3

import subprocess
import time

allowed_chromium_windows = set()

COMBO_TIMES = 5
COMBO_INTERVAL_S = 15
# Keeps track of chromium window openings in a 15 seconds range
combo_state = []

while True:
    currently_open_chromium_windows = []
    output = (
        subprocess.check_output(
            ["wmctrl -l -x | grep \"chromium\" | awk '{ print $1 }'"], shell=True
        )
        .decode("utf-8")
        .strip()
    )
    currently_open_chromium_windows = set()
    if output != "":
        currently_open_chromium_windows = set(output.split("\n"))

    # Remove no more opened allowed windows from `allowed_chromium_windows`
    allowed_chromium_windows = allowed_chromium_windows.intersection(
        currently_open_chromium_windows
    )

    new_opened_windows = currently_open_chromium_windows.difference(
        allowed_chromium_windows
    )

    combo_state = [
        state for state in combo_state if time.time() - state < COMBO_INTERVAL_S
    ]

    if len(new_opened_windows) > 0:
        combo_state.append(time.time())
        if len(combo_state) >= COMBO_TIMES:
            print(f"Allowing chromium windows {new_opened_windows}")
            combo_state.clear()
            allowed_chromium_windows.update(new_opened_windows)
        else:
            for window in new_opened_windows:
                print(f"Closing chromium window {window}")
                subprocess.check_output(["wmctrl", "-i", "-c", window])
                subprocess.check_output(["notify-send", "--icon=anki", "--app-name=Revise Anki!", "Hey, stay focused!"])
                subprocess.Popen("anki", start_new_session=True)

    time.sleep(1)
