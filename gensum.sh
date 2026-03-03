#!/bin/bash
cache="$HOME/.cache/gensum.cache"
mkdir -p "$HOME/.cache/"

ARCH_HASH=$(sha256sum dependencies/basic-arch.txt | cut -d' ' -f1)
echo $ARCH_HASH

if [ -f "$HOME/.cache/gensum.cache" ]; then
    ARCH_LOADED_HASH=$(cat "$HOME/.cache/gensum.cache")
    echo $ARCH_LOADED_HASH
else
    ARCH_LOADED_HASH="none"
    echo $ARCH_LOADED_HASH
    echo "Creating hash..."
    touch $HOME/.cache/gensum.cache
    echo ""
    if [ ! -s "$cache" ]; then
        echo "$ARCH_HASH" > "$cache"
    else
        sed -i "1s/.*/$ARCH_HASH/" "$cache"
    fi
fi

if [[ "$ARCH_HASH" -eq "$LOADED_HASH" ]]; then
    echo "Dependencies haven't changed. Keeping cache."
else
    echo "Dependencies changed or cache missing. Reseting cache..."
    curl -LO https://raw.githubusercontent.com/clippyricer/dotfiles/refs/heads/main/setup.cache
    cp setup.cache "$HOME/.cache/setup.cache"
fi
