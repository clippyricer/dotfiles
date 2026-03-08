#!/usr/bin/env bash

# Use 'nix-shell -p gum' if gum isn't installed yet
# No more /usr/bin/python or breaking system packages. 
# We assume dependencies are handled by your Nix configuration.

LOG_FILE="log.txt"
scriptdir=$(pwd)

# On NixOS, we don't 'install' Hyprland via script. 
# We enable it in configuration.nix: programs.hyprland.enable = true;

# Use Nix-native fonts instead of curl/tar to /usr/share
# Add 'pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }' to your config.

# --- Backup Logic ---
echo "Backing up existing configs..."
mkdir -p "../backup/config/"
# (Keep your existing backup loop here, it works fine in $HOME)

# --- Dotfiles (Stow) ---
# This part works on NixOS as long as it's in your home folder
cd "$scriptdir/.."
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

# --- Systemd Services ---
# On NixOS, we define services in Nix. 
# But for a quick user-level service:
mkdir -p "$HOME/.config/systemd/user/"
cp "$scriptdir/../other/spotify-notify.service" "$HOME/.config/systemd/user/"
systemctl --user daemon-reload
systemctl --user enable --now spotify-notify.service

echo "NixOS setup step complete."
echo "Remember to run 'sudo nixos-rebuild switch --flake .#yourConfig' to apply system changes."
