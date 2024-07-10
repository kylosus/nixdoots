#!/bin/sh

dunstctl set-paused true
i3lock -t -i "$1" --nofork
dunstctl set-paused false
