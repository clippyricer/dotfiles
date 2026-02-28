#!/bin/bash

# Current dir
dotdir=`pwd`

#Install gum
sudo pacman -S gum --noconfirm
pip install chardet lib3 datetime requests statistics urllib3 dulwich
# Instlall paru
sudo pacman -S base-devel --noconfirm
pushd $HOME; git clone https://aur.archlinux.org/paru.git
cd paru/; makepkg -si; popd

# Install hyprland deps
clear
echo ""
gum confirm "Would you like to install hyprland?"

if [ $? == 0 ]; then
    paru -S $(cat dependencies/hyprland-arch.txt) --noconfirm
fi

# Install basic deps
sudo pacman -S $(cat dependencies/basic-arch.txt) --noconfirm


# Backup current config
mkdir -p backup/config/

if [ -d $HOME/.config/kitty ]; then
    cp -r $HOME/.config/kitty ./backup/config/
fi

if [ -d $HOME/.config/.vim ]; then
    cp -r $HOME/.config/.vim ./backup/config/
fi

if [ -f $HOME/.vimrc ]; then
    cp $HOME/.vimrc ./backup/vimrc
fi

if [ -f $HOME/.p10k.zsh ]; then
    cp $HOME/.p10k.zsh ./backup/p10k.zsh
fi

if [ -f $HOME/.zshrc ]; then
    cp $HOME/.zshrc ./backup/zshrc
fi

if [ -d $HOME/.config/eza ]; then
    cp -r $HOME/.config/eza ./backup/config/
fi

if [ -d $HOME/.config/btop ]; then
    cp -r $HOME.config/btop ./backup/config/
fi

# Backup hyprland config
if [ $? == 0 ]; then
    echo "I will ask you questions. If you don't use what I ask you about"
    echo "leave it blank. Make sure to specify FULL path ex(/home/user/.config/dunst)"
    sleep 4
    echo ""
    read -p "Input your dunst config path: " dunstpath
    read -p "Input your hyprland config path: " hyprpath
    read -p "Input your rofi config path: " rofipath
    read -p "Input your waybar config path: " waybarpath
    echo ""

    if [[ ! $dunstpath == "" ]]; then
        cp -r $dunstpath ./backup/config/
    fi

    if [[ ! $hyprpath == "" ]]; then
        cp -r $hyprpath ./backup/config/
    fi

    if [[ ! $rofipath == "" ]]; then
        cp -r $rofipath ./backup/config/
    fi

    if [[ ! $waybarpath == "" ]]; then
        cp -r $waybarpath ./backup/config/
    fi
fi

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install JetBrainsMono NerdFont and icons
curl -LO https://github.com/clippyricer/dotfiles/releases/download/v0.0.1/assets.tar; tar -xvf assets.tar
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
if [ ! -d "/usr/share/fonts/JetBrainsMono" ]; then
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
stow eza --adopt
stow btop --adopt

# Install icons for hyprland
if [ $? == 0 ]; then
    stow hyprland --adopt
    if [ ! -d "/usr/share/icons/FontAwsome" ]; then
        sudo mkdir -p /usr/share/icons/FontAwesome; icons="/usr/share/icons/FontAwesome/"
    fi
    sudo cp icons/* $icons
    mkdir -p $HOME/Pictures/Wallpapers; mv wallpapers/* $HOME/Pictures/Wallpapers
fi

# Install spotify
sudo cp other/spotify-notify /usr/local/bin

if [ ! -d "$HOME/.config/systemd/user" ]; then
    mkdir -p $HOME/.config/systemd/user/
fi

cd $dotdir
cp other/spotify-notify.service $HOME/.config/systemd/user/

# Install arch wallapaper for hyprland
if [ $? == 0 ]; then
    if [ ! -d "$HOME/Pictures/Wallpapers"]; then
        mkdir -p $HOME/Pictures/Wallpapers/
    fi
    cp wallpapers/* $HOME/Pictures/Wallpapers/
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
if [ $? == 0 ]; then
    if [ ! -d "$HOME/Hyprland" ]; then
        git clone --recursive https://github.com/hyprwm/Hyprland; cd Hyprland/
    else
        cd $HOME/Hyprland; git pull --force
    fi

    mkdir build; cd build/
    cmake -G Ninja ..; sudo ninja && sudo ninja install
    systemctl enable ly@tty2.service; systemctl disable getty@tty2.service
    rustup override set stable || exit -1; rustup update stable; git clone https://github.com/coffebar/waybar-module-pacman-updates.git /tmp/waybar-module-pacman-updates
    pushd /tmp/waybar-module-pacman-updates && cargo build --release; mkdir -p ~/.local/bin; cp target/release/waybar-module-pacman-updates ~/.local/bin/
    popd && rm -rf /tmp/waybar-module-pacman-updates 
fi

cd $HOME

# Options
read -p "Would you like to install the minegrub bootloader theme?: (y/n) " minegrub
read -p "Would you like to install Spotify add block?: (y/n) " spotx
read -p "Would you like to install Ly configuration?: (y'n) " ly

if [[ $minegrub == "Y" || $minegrub == "y" ]]; then
    git clone https://github.com/Lxtharia/double-minegrub-menu.git /tmp/double-minegrub-menu; pushd /tmp/double-minegrub-menu
    sudo ./install.sh
    popd
fi

if [[ $ly == "y" || $ly == "Y" ]]; then
    sudo git clone https://github.com/clippyricer/ly-config.git /etc/ly
fi

if [[ $spotx == "y" || $spotx == "Y" ]]; then
    cd $HOME; bash <(curl -sSL https://spotx-official.github.io/run.sh)
fi

if [ $? == 0 ]; then
    git clone https://codeberg.org/LGFae/awww.git /tmp/awww
    pushd /tmp/awww; cargo build --release
    sudo cp target/release/awww /usr/local/bin; sudo cp target/release/awww-daemon /usr/local/bin
    ./doc/gen.sh; sudo cp doc/generated* /usr/share/man
fi

clear
echo "Done!"
echo "To see effects close your terminal and open up kitty to see the effects"
