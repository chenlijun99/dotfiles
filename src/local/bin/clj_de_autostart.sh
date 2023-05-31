#!/usr/bin/env bash
#
# This script is invoked as DE login script.
# Its purpose include
#
# * autostart some applications after some delay.
#

# Delay some time... Otherwise the following programs don't function well.
sleep 10

function run_if_available() {
	if command -v "$1" &>/dev/null; then
		"$1" &
	fi
}

# If teams is autostarted too early, often it fails to startup
run_if_available teams
# If thunderbird is autostarted too early, it's GUI remains stuck
run_if_available thunderbird
# If slack is autostarted too early, it requires re-authentication for all the
# workspaces
run_if_available slack
# If syncthingtray is autostarted too early, it complains that no systemtray
# is available yet.
run_if_available syncthingtray

# Start running in background
clj_stay_focused &
