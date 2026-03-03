#!/bin/bash
gensumcache="$HOME/.cache/gensum.cache"
mkdir -p "$HOME/.cache/"

PACMAN_HASH=$(md5sum ../dependencies/pacman-arch.txt | cut -d' ' -f1)
echo "NEW HASH IS $PACMAN_HASH"

if [ -f "$HOME/.cache/gensum.cache" ]; then
    PACMAN_LOADED_HASH=$(sed -n '1p' $HOME/.cache/gensum.cache)
    echo "CURRENT HASH IS $PACMAN_LOADED_HASH"
    sleep 1.5
else
    PACMAN_LOADED_HASH="NONE"
    echo "CURRENT HASH IS $PACMAN_LOADED_HASH"
    sleep 1.5
    echo "Creating hash file..."
    cp "../gensum.cache" "$HOME/.cache/gensum.cache"
    echo ""
fi


if [[ "$PACMAN_HASH" == "$PACMAN_LOADED_HASH" ]]; then
    echo "Dependencies haven't changed. Keeping cache."
else
    echo "Dependencies changed or cache missing. Reseting cache..."
    curl -LO --output-dir ../ https://raw.githubusercontent.com/clippyricer/dotfiles/refs/heads/main/setup.cache --progress-bar
    cp ../setup.cache "$HOME/.cache/setup.cache"
    setupcache="$HOME/.cache/setup.cache"
    for i in 2 3 4 5; do
        sed -i "${i}c\\1" $setupcache
    done
        sed -i "1s/.*/$PACMAN_HASH/" "$gensumcache"
fi
