#!/bin/bash

icon=$HOME/.config/i3/lock.png
img=/tmp/lock.png

flameshot full -r > $img
convert $img -blur 0x4 $img
convert $img $icon -gravity center -composite $img

i3lock -c 000000 -i $img --show-failed-attempts --ignore-empty-password --nofork
