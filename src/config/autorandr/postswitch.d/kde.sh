#!/usr/bin/env bash

if [[ $XDG_CURRENT_DESKTOP == "KDE" ]]; then
	kwin_x11 --replace &
fi
