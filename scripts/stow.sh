#!/bin/bash
# Stows all files in the current dir

cd ..
choice=`gum choose Stow\ all Unstow\ all`

if [[ $choice == "Stow all" ]]; then
    for dir in */; do
        dir=${dir%/}
        case "$dir" in
            dependencies|hyprland|release|archive|backup|icons|other|scripts|wallpapers)
                continue
                ;;
            *)
                echo "Applying config for $dir"
                stow -D "$dir" 2>/dev/null || true
                stow "$dir" --adopt
                ;;
        esac
    done
fi


if [[ $choice == "Unstow all" ]]; then
    for dir in */; do
        dir=${dir%/}
        case "$dir" in
            dependencies|hyprland|release|archive|backup|icons|other|scripts|wallpapers)
                continue
                ;;
            *)
                echo "Deleting config for $dir"
                stow -D "$dir" 2>/dev/null || true
                ;;
        esac
    done
fi
