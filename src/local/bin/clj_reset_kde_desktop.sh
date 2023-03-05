#!/usr/bin/env bash
#
# This script resets the KDE desktop environment. This is used when I hit
# some error in KDE.
#

if [[ $XDG_CURRENT_DESKTOP == "KDE" ]]; then
	kwin_x11 --replace &
	kquitapp5 plasmashell
	kstart5 plasmashell
fi
