#!/usr/bin/env bash

IMG_DIR="/tmp/chenlijun99/scripts/lock"
IMG_PATH="${IMG_DIR}/screen.png"

mkdir -p "${IMG_DIR}"
rm -f ${IMG_DIR}/*

# Wait for rofi menu to close
sleep 0.2

scrot "${IMG_PATH}"
convert "${IMG_PATH}" -scale 10% -blur 0x2.5 -resize 1000% "${IMG_PATH}"
[[ -f $1 ]] && convert "${IMG_PATH}" $1 -gravity center -composite -matte "${IMG_PATH}"
i3lock -i "${IMG_PATH}"
