#!/bin/bash

# Current dir
dotdir=`pwd`

# Install hyprland deps
read -p "Would you like to install hyprland?: (y/n) " hypr

if [[ $hypr == "y" || $hypr == "Y" ]]; then
    yay -S $(cat dependencies/hyprland-arch.txt)
fi

# Install basic deps
sudo pacman -S $(cat dependencies/basic-arch.txt)

# Install JetBrainsMono NerdFont
curl -OLv https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
if [[ ! -d "/usr/share/fonts/JetBrainsMono" ]]; then
    mkdir -p /usr/share/fonts/JetBrainsMono/
fi

fontdir="/usr/share/fonts/JetBrainsMono/"

tar -xvf JetBrainsMono.tar.xz -C $fontdir; rm -rf JetBrainsMono.tar.xz
cd $fontdir; sudo rm -rf *.md *.txt
cd $dotdir
fc-cache -frv

# Initlize config
stow kitty --adopt
stow vim --adopt
stow zsh --adopt

# Install icons for hyprland
if [[ $hypr == "y" || $hypr == "Y" ]]; then
    stow hyprland --adopt
    if [[ ! -d "/usr/share/icons/FontAwsome" ]]; then
        sudo mkdir -p /usr/share/icons/FontAwesome; icons="/usr/share/icons/FontAwesome/"
    fi
    sudo cp icons/* $icons
    mkdir -p $HOME/Pictures/Wallpapers; mv arch.png $HOME/Pictures/Wallpapers
fi

# Install spotify
sudo cp spotify-notify /usr/local/bin

if [[ ! -d "$HOME/.config/systemd/user" ]]; then
    mkdir -p $HOME/.config/systemd/user/
fi

cp spotify-notify.service $HOME/.config/systemd/user/

# Install arch wallapaper for hyprland
if [[ $hypr == "y" || $hypr == "Y" ]]; then
    if [ ! -d "$HOME/Pictures/Wallpapers"]; then
        mkdir -p $HOME/Pictures/Wallpapers/
    fi
    cp arch.png $HOME/Pictures/Wallpapers/
fi

# Install p10k
cd $HOME
if [ ! -d "$HOME/powerlevel10k" ]; then
    git clone https://github.com/romkatv/powerlevel10k.git
else
    cd $HOME/powerlevel10k; git pull --force; cd $HOME
fi

# Enable dunst spotify
systemctl --user daemon-reload; systemctl --user enable --now spotify-notify.service
systemctl --user enable spotify-notify.service; systemctl --user start spotify-notify.service


# Install Hyprland
if [[ $hypr == "y" || $hypr == "Y" ]]; then
    if [ ! -d "$HOME/Hyprland" ]; then
        git clone --recursive https://github.com/hyprwm/Hyprland; cd Hyprland/
    else
        cd $HOME/Hyprland; git pull --force
    fi

    mkdir build; cd build/
    cmake -G Ninja ..; sudo ninja && sudo ninja install
    systemctl enable ly@tty2.service; systemctl disable getty@tty2.service
fi

cd $HOME

# Options
read -p "Would you like to install the minegrub bootloader theme?: (y/n) " minegrub
read -p "Would you like to install Spotify add block?: (y/n) " spotx

if [[ $minegrub == "Y" || $minegrub == "y" ]]; then
    git clone https://github.com/Lxtharia/double-minegrub-menu.git; cd double-minegrub-menu
    sudo ./install.sh
fi

if [[ $spotx == "y" || $spotx == "Y" ]]; then
    cd $HOME; bash <(curl -sSL https://spotx-official.github.io/run.sh)
fi

clear
echo "Done!"
echo "To see effects close your terminal and open up kitty to see the effects"
