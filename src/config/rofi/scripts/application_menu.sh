#!/bin/bash

# Custom Rofi Script

BORDER="#FFFFFF"
SEPARATOR="#FFFFFF"
FOREGROUND="#FFFFFF"
BACKGROUND="#263238"
BACKGROUND_ALT="#263238"
HIGHLIGHT_BACKGROUND="#FFA000"
HIGHLIGHT_FOREGROUND="#FFFFFF"

BLACK="#000000"
WHITE="#ffffff"
RED="#e53935"
GREEN="#43a047"
YELLOW="#fdd835"
BLUE="#1e88e5"
MAGENTA="#00897b"
CYAN="#00acc1"
PINK="#d81b60"
PURPLE="#8e24aa"
INDIGO="#3949ab"
TEAL="#00897b"
LIME="#c0ca33"
AMBER="#ffb300"
ORANGE="#fb8c00"
BROWN="#6d4c41"
GREY="#757575"
BLUE_GREY="#546e7a"
DEEP_PURPLE="#5e35b1"
DEEP_ORANGE="#f4511e"
LIGHT_BLUE="#039be5"
LIGHT_GREEN="#7cb342"

view=${INITIAL_VIEW:-combi}

# Launch Rofi
rofi -no-lazy-grab -modi combi,window -combi-modi window,drun -show "$view" -sidebar-mode \
-display-combi "Quick launch" -drun-display-format "{name}" \
-display-drun "Apps" \
-display-window "Windows" \
-bw 0 \
-lines 7 \
-line-padding 15 \
-padding 30 \
-width 60 \
-columns 2 \
-show-icons -icon-theme "Papirus" \
-theme-str 'element-icon { size: 24px; margin: 0px 10px 0px 0px; }' \
-font "Hack Nerd Font 14" \
-color-enabled true \
-color-window "$BACKGROUND,$BORDER,$SEPARATOR" \
-color-normal "$BACKGROUND_ALT,$FOREGROUND,$BACKGROUND_ALT,$HIGHLIGHT_BACKGROUND,$HIGHLIGHT_FOREGROUND" \
-color-active "$BACKGROUND,$MAGENTA,$BACKGROUND_ALT,$HIGHLIGHT_BACKGROUND,$HIGHLIGHT_FOREGROUND" \
-color-urgent "$BACKGROUND,$YELLOW,$BACKGROUND_ALT,$HIGHLIGHT_BACKGROUND,$HIGHLIGHT_FOREGROUND"
