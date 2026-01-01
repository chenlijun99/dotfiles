#!/usr/bin/env python3

import sys

from pathlib import Path


def log(msg):
    """Simple logging to stdout."""
    print(f"[setup] {msg}")


def add_to_git_exclude(project_root: Path, entry: str):
    """
    Adds an entry to .git/info/exclude if it's not already present.
    Ensures idempotency.
    """
    exclude_path = project_root / ".git" / "info" / "exclude"

    if not exclude_path.parent.is_dir():
        log(f"Error: {exclude_path.parent} does not exist. Are you in a git root?")
        return False

    if not exclude_path.exists():
        exclude_path.touch()

    content = exclude_path.read_text()
    lines = [line.strip() for line in content.splitlines()]

    if entry.strip("/") in [l.strip("/") for l in lines]:
        log(f"'{entry}' already present in .git/info/exclude. Skipping.")
        return True

    try:
        with exclude_path.open("a") as f:
            # Ensure we start on a new line if the file isn't empty and doesn't end with a newline
            if content and not content.endswith("\n"):
                f.write("\n")
            f.write(f"{entry}\n")
        log(f"Added '{entry}' to .git/info/exclude")
        return True
    except Exception as e:
        log(f"Failed to update .git/info/exclude: {e}")
        return False


def setup_ignore_file(project_root: Path):
    """
    Creates the .ignore file with the required content.
    Asks for confirmation if the file already exists.
    """
    ignore_file = project_root / ".ignore"
    required_content = "!personal/\n"

    if ignore_file.exists():
        existing_content = ignore_file.read_text()
        if existing_content == required_content:
            log("'.ignore' file already exists with correct content. Skipping.")
            return

        response = input(
            f"'.ignore' already exists with different content. Overwrite? [y/N]: "
        ).lower()
        if response != "y":
            log("Skipping '.ignore' file creation as per user request.")
            return

    try:
        ignore_file.write_text(required_content)
        log(f"Created/Updated '.ignore' at {ignore_file}")
    except Exception as e:
        log(f"Failed to create .ignore file: {e}")


def main():
    # Identify project root
    project_root = Path.cwd()

    if not (project_root / ".git").is_dir():
        print(f"Error: {project_root} is not a git repository root.")
        sys.exit(1)

    log(f"Setting up project scaffolding at: {project_root}")

    # 1. Add `personal/` to .git/info/exclude
    add_to_git_exclude(project_root, "personal/")

    # 2. Add `.ignore` to .git/info/exclude
    add_to_git_exclude(project_root, ".ignore")

    # 3. Create/Update the .ignore file in the project root.
    setup_ignore_file(project_root)

    log("Setup complete.")
    log(
        "Note: Remember to symlink your PKM project folder to 'personal/' to complete the workflow."
    )


if __name__ == "__main__":
    main()
