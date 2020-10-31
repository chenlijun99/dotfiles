#!/usr/bin/env bash

if [[ $XDG_CURRENT_DESKTOP == "i3" ]]; then
	i3-msg restart
fi
