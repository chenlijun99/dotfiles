#!/usr/bin/env bash

tmux list-windows -a -F "#{session_name}:#{window_name}:#{window_id}" \
| fzf --reverse \
| awk -F ":" '{print $1 " " $3}' \
| xargs --no-run-if-empty -L1 sh -c 'tmux switch-client -t $0; tmux select-window -t $1'
