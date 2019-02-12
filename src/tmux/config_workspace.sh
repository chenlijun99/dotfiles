#!/usr/bin/env bash

# rename sesion according to current name

session_name=$(basename `tmux run-shell "echo #{pane_current_path}"` |  sed -e 's/\.//g')
tmux list-sessions -F "#{session_name}" | grep -w "$session_name" &> /dev/null
if [[ $? -ne 0 ]]; then
	tmux rename-session "$session_name"
fi

# handle main window
tmux list-windows -F "#{window_name}" | grep -w edit &> /dev/null
if [[ $? -ne 0 ]]; then
	tmux rename-window "edit"
fi

# create other windows if missing
declare -a workspace_windows=(
	"build"
	"git"
	"documentation"
	"misc"
)
for window in "${workspace_windows[@]}"
do
	tmux list-windows -F "#{window_name}" | grep -w $window &> /dev/null
	if [[ $? -ne 0 ]]; then
		tmux new-window -k -d -c "#{pane_current_path}" -n $window
	fi
done
