#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar, using default config location ~/.config/polybar/config
mkdir -p /tmp/polybar/
IFS=$'\n'
for monitor in $(polybar --list-monitors); do
	monitor_name=$(echo $monitor | cut -d":" -f1)
	echo "---" | tee -a "/tmp/polybar/${monitor_name}.log"
	if [[ $monitor == *"primary"* ]]; then
		MONITOR=$monitor_name polybar --reload top-with-tray >> "/tmp/polybar/${monitor_name}.log" 2>&1 & disown 
	else
		MONITOR=$monitor_name polybar --reload top  >> "/tmp/polybar/${monitor_name}.log" 2>&1 & disown 
	fi
done
unset IFS

echo "Polybar launched..."
