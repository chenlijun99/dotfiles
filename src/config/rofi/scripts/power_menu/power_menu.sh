#!/usr/bin/env bash

rofi_command="rofi"
uptime=$(uptime -p | sed -e 's/up //g')

# Options
shutdown="Shutdown"
reboot="Reboot"
lock="Lock"
suspend="Suspend"
logout="Logout"

# Variable passed to rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

chosen="$(echo -e "$options" | $rofi_command -p "UP - $uptime" -dmenu -selected-row 2)"
case $chosen in
	$shutdown)
		systemctl poweroff
		;;
	$reboot)
		systemctl reboot
		;;
	$lock)
		~/.config/i3/scripts/lock.sh
		;;
	$suspend)
		~/.config/i3/scripts/lock.sh; systemctl suspend
		;;
	$logout)
		i3-msg exit
		;;
esac
