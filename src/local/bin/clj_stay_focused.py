#!/usr/bin/env python3

import subprocess
import time

COMBO_TIMES = 5
COMBO_INTERVAL_S = 15


class BlocklistProgram:
    def __init__(self, program_window_name) -> None:
        self.program_window_name = program_window_name
        # Keeps track of window openings in a 15 seconds range
        self.combo_state = []
        self.allowed_windows = set()

    def check(self) -> None:
        currently_open_windows = []
        output = (
            subprocess.check_output(
                [
                    f"wmctrl -l -x | grep \"{self.program_window_name}\" | awk '{{ print $1 }}'"
                ],
                shell=True,
            )
            .decode("utf-8")
            .strip()
        )
        currently_open_windows = set()
        if output != "":
            currently_open_windows = set(output.split("\n"))

        # Remove no more opened allowed windows from `allowed_windows`
        self.allowed_windows = self.allowed_windows.intersection(currently_open_windows)

        new_opened_windows = currently_open_windows.difference(self.allowed_windows)

        self.combo_state = [
            state
            for state in self.combo_state
            if time.time() - state < COMBO_INTERVAL_S
        ]

        if len(new_opened_windows) > 0:
            self.combo_state.append(time.time())
            if len(self.combo_state) >= COMBO_TIMES:
                print(
                    f"Allowing {self.program_window_name} windows {new_opened_windows}"
                )
                self.combo_state.clear()
                self.allowed_windows.update(new_opened_windows)
            else:
                for window in new_opened_windows:
                    print(f"Closing {self.program_window_name} window {window}")
                    subprocess.check_output(["wmctrl", "-i", "-c", window])
                    subprocess.check_output(
                        [
                            "notify-send",
                            "--icon=anki",
                            "--app-name=Revise Anki!",
                            "Hey, stay focused!",
                        ]
                    )
                    subprocess.Popen("anki", start_new_session=True)


programs = [
    BlocklistProgram("chromium"),
    BlocklistProgram("microsoft-edge.Microsoft-edge"),
]

while True:
    for program in programs:
        program.check()
    time.sleep(1)
