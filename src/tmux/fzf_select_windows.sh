#!/usr/bin/env bash

tmux list-windows -F "#{window_name}:#{window_id}" \
| fzf --reverse \
| cut -d "@" -f 2 \
| xargs -I{} tmux select-window -t @{}
