#!/bin/bash

killall waybar
killall dunst

dunst &
waybar -c ~/.config/waybar/config.jsonc & -s ~/.config/waybar/style.css
