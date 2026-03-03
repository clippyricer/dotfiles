#!/bin/bash
cache="$HOME/.cache/gensum.cache"
mkdir -p "$HOME/.cache/"

ARCH_HASH=$(md5sum dependencies/basic-arch.txt | cut -d' ' -f1)
echo "NEW HASH IS $ARCH_HASH"

if [ -f "$HOME/.cache/gensum.cache" ]; then
    ARCH_LOADED_HASH=$(cat "$HOME/.cache/gensum.cache")
    echo "CURRENT HASH IS $ARCH_LOADED_HASH"
    sleep 2
else
    ARCH_LOADED_HASH="none"
    echo "CURRENT HASH IS $ARCH_LOADED_HASH"
    sleep 2
    echo "Creating hash..."
    touch $HOME/.cache/gensum.cache
    echo ""
fi


if [[ "$ARCH_HASH" == "$ARCH_LOADED_HASH" ]]; then
    echo "Dependencies haven't changed. Keeping cache."
else
    echo "Dependencies changed or cache missing. Reseting cache..."
    curl -LO https://raw.githubusercontent.com/clippyricer/dotfiles/refs/heads/main/setup.cache
    cp setup.cache "$HOME/.cache/setup.cache"
    if [ ! -s "$cache" ]; then
        echo "$ARCH_HASH" > "$cache"
    else
        sed -i "1s/.*/$ARCH_HASH/" "$cache"
    fi
fi
