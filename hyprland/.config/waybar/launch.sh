#!/usr/bin/env bash

killall -q waybar
killall -q dunst
pkill waybar
pkill dunst

while pgrep -u $UID -x waybar >/dev/null; do sleep 1; done

export PATH=$PATH:$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin

WIDTH=$(hyprctl monitors -j | jq '.[0].width')
WIDTH=$((WIDTH - 20))
sed -i "s/\"width\": .*/\"width\": $WIDTH,/" ~/.config/waybar/config.jsonc

waybar -c ~/.config/waybar/config.jsonc & -s ~/.config/waybar/style.css
dunst &
