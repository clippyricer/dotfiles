#!/bin/bash
# Stows all files in the current dir

choice=`gum choose Stow\ all Unstow\ all`

if [[ $choice == "Stow all" ]]; then
    for dir in *; do
        if [[ -d $dir && ! $dir == "dependencies" && ! $dir == "hyprland" && ! $dir == "release"&& ! $dir == "archive" && ! $dir == "backup" && ! $dir == "icons" && ! $dir == "other" && ! $dir == "wallpapers" ]]; then
            echo "Applying config for $dir"
            stow $dir --adopt
        fi
    done
fi

if [[ $choice == "Unstow all" ]]; then
    for dir in *; do
        if [[ -d $dir && ! $dir == "dependencies" && ! $dir == "hyprland" && ! $dir == "release" && ! $dir == "archive"  && ! $dir == "backup" && ! $dir == "icons" && ! $dir == "other" && ! $dir == "wallpapers" ]]; then
            echo "Deleting config for $dir"
            stow -D $dir
        fi
    done
fi
