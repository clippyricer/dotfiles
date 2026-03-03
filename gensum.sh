#!/bin/bash
cache="$HOME/.cache/gensum.cache"
mkdir -p "$HOME/.cache/"
touch "$HOME/.cache/gensum.cache"

ARCH_HASH=$(sha256sum dependencies/basic-arch.txt | cut -d' ' -f1)
echo $ARCH_HASH
