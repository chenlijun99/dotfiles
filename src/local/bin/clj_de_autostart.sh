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
# Recently haven't been using Teams. For now comment out.
# run_if_available teams-for-linux

# If thunderbird is autostarted too early, it's GUI remains stuck
run_if_available thunderbird

# If slack is autostarted too early, it requires re-authentication for all the
# workspaces
# Recently haven't been using slack. For now comment out.
# run_if_available slack

# Start running in background
clj_stay_focused &
