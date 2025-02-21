#!/usr/bin/env python3

import argparse
import subprocess


def toggle_or_launch(
    program_name: str, search_term: str, create_new: bool, program_args: list[str]
) -> None:
    if create_new:
        # Launch a new instance
        subprocess.Popen([program_name, *program_args])
        return

    # Search for existing windows
    try:
        result: bytes = subprocess.check_output(["kdotool", "search", search_term])
        window_ids: list[str] = [id for id in result.decode().strip().split("\n") if id != ""]
    except subprocess.CalledProcessError:
        window_ids = []

    if len(window_ids) == 0:
        # Launch a new instance
        subprocess.Popen([program_name, *program_args])
    else:
        # Get active window id
        try:
            active_window_id = (
                subprocess.check_output(["kdotool", "getactivewindow"]).decode().strip()
            )
        except subprocess.CalledProcessError:
            active_window_id = ""

        if active_window_id in window_ids:
            if len(window_ids) == 1:
                # Minimize the current window
                subprocess.run(
                    ["kdotool", "windowminimize", active_window_id], check=False
                )
            else:
                # Cycle to the next window
                current_index: int = window_ids.index(active_window_id)
                next_index: int = (current_index + 1) % len(window_ids)
                next_window_id: str = window_ids[next_index]
                subprocess.run(
                    ["kdotool", "windowactivate", next_window_id], check=False
                )
        else:
            # Activate the first window in the list
            subprocess.run(["kdotool", "windowactivate", window_ids[0]], check=False)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Toggle or launch an application.",
    )
    parser.add_argument(
        "program_name",
        help="The name of the program to launch (e.g., konsole, firefox).",
    )
    parser.add_argument(
        "--search_term",
        nargs="?",
        default=None,
        help="The search term to use to find the program's window. Defaults to program name.",
    )
    parser.add_argument(
        "--new-instance",
        action="store_true",
        default=False,
        dest="create_new",
        help="Always launch a new instance. If not specified, toggles or cycles through existing ones.",
    )
    parser.add_argument("program_args", nargs=argparse.REMAINDER)

    args = parser.parse_args()

    if args.search_term is None:
        args.search_term = args.program_name

    toggle_or_launch(
        args.program_name, args.search_term, args.create_new, args.program_args
    )


if __name__ == "__main__":
    main()
