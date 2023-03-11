#!/usr/bin/env bash
#
# This script shows a QR code on the terminal that I have to scan.
# After some seconds, the system suspends.
#
# Let this serve as gentle nudge for me to go to sleep early.
#

# Ignore SIGINT so that it is harder for myself to cheat.

trap '' SIGINT
qrencode -t utf8 "TIME TO SLEEP BOY!"
sleep 17
systemctl suspend
