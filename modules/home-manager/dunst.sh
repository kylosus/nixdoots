#!/bin/sh

. "$1"

dunst \
  -frame_width 2 \
  -lb "${color0}" \
  -nb "${color0}" \
  -cb "${color0}" \
  -lf "${color7}" \
  -bf "${color7}" \
  -cf "${color7}" \
  -nf "${color7}"

