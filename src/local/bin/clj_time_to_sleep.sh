#!/usr/bin/env bash
#
# This script shows a QR code on the terminal that I have to scan.
# After some seconds, the system suspends.
#

qrencode -t utf8 "TIME TO SLEEP BOY!"
sleep 17
systemctl suspend
