#!/usr/bin/env bash

`tmux list-windows -a -F "#{session_name}:#{window_name}:#{window_id}:#{pane_pid}" \
| fzf -m --reverse \
| awk -F ":" '{print $1 " " $2 " " $3 " " $4}'`
| while read session_name window_name window_id pane_pid; do
	if [[ -z $(pgrep -P "$pane_pid") ]]; then
		tmux kill-window -t "$session_name:$window_id"
	else
		tmux confirm-before -p \
			"Kill window $session_name:$window_name? There are running process (y/n)" \
			"kill-window -t $session_name:$window_id"
	fi
done
