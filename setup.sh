#!/bin/bash

read -p "Would you like to install hyprland?: (y/n) " hypr
if [ $hypr == "y" ]; then
    yay -S $(cat dependencies/hyprland-arch.txt)
fi

sudo pacman -S $(cat dependencies/basic-arch.txt)

curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
tar -xvf JetBrainsMono.tar.xz && sudo mkdir -p /usr/share/fonts/JetBrainsMono/
sudo mv *.ttf /usr/share/fonts/JetBrainsMono/
fc-cache -frv && rm JetBrainsMono.tar.xz
stow kitty --adopt
stow vim --adopt
stow zsh --adopt

rm -rf OFL.txt
git reset --hard HEAD

if [ $hypr == "y" ]; then
    stow hyprland --adopt
    sudo mkdir -p /usr/share/icons/FontAwesome
    sudo cp icons/* /usr/share/icons/FontAwesome
    sudo rm -rf /etc/xdg/waybar/ && sudo rm -rf /etc/rofi/
    sudo rm -rf /etc/dunst/
fi

sudo cp spotify-notify /usr/local/bin
mkdir -p $HOME/.config/systemd/user/
cp spotify-notify.service $HOME/.config/systemd/user/

mkdir -p $HOME/Pictures/Wallpapers/
cp arch.png $HOME/Pictures/Wallpapers/

cd $HOME && git clone https://github.com/romkatv/powerlevel10k.git
systemctl --user daemon-reload
systemctl --user enable --now spotify-notify.service
systemctl --user enable spotify-notify.service
systemctl --user start spotify-notify.service


if [ $hypr == "y" ]; then
    git clone --recursive https://github.com/hyprwm/Hyprland
    cd Hyprland
    make all && sudo make install
fi

echo "Done!"
echo "To see effects close your terminal and open up kitty to see the effects"
