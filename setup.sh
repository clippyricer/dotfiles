#!/bin/bash
set -e
dotdir=$(pwd)
hyprinstall=1
hyprconfig=0
paruinstall="NO"

# Update pkgs and install script deps
sudo pacman -Syu --noconfirm
sudo pacman -S gum base-devel python3 python-pip --noconfirm
pip install chardet lib3 datetime requests statistics urllib3 dulwich --break-system-packages

# Install paru
if [[ ! -x /usr/bin/paru ]]; then
    pushd $HOME; git clone https://aur.archlinux.org/paru.git
    cd paru/ && makepkg -si --noconfirm; popd
fi

# Install hyprland deps
clear
if gum confirm "Would you like to install hyprland/update?"; then
    hyprinstall=0
    aurdeps=$(cat dependencies/aur-arch.txt)
    if [[ ! -f "$HOME/.cache/aurdeps.cache" ]]; then
        paru -S $aurdeps --noconfirm
        mkdir -p "$HOME/.cache"; touch "$HOME/.cache/aurdeps.cache"
        paruinstall="YES"
    else
        paru -Syu --noconfirm
    fi
fi

# Remove packaged rust
if [[ $paruinstall == "YES"  ]]; then
  paru -R rust --noconfirm || true
fi

# Install basic deps
archdeps=$(cat dependencies/basic-arch.txt)
sudo pacman -S $archdeps --noconfirm --needed

# Install non pkg dependencies
nonpkgdeps() {
    # Rust & Other & Fonts
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    curl -LO https://github.com/clippyricer/dotfiles/releases/download/v0.1.0/assets.tar; tar -xvf assets.tar
    
    fontdir="/usr/share/fonts/JetBrainsMono/"
    if [[ ! -d "/usr/share/fonts/JetBrainsMono" ]]; then
        sudo mkdir -p /usr/share/fonts/JetBrainsMono/
    fi

    curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
    sudo tar -xvf JetBrainsMono.tar.xz -C $fontdir; rm -rf JetBrainsMono.tar.xz && rm -rf assets.tar
    cd $fontdir; sudo rm -rf *.md *.txt
    cd $dotdir
    fc-cache -frv


    # Oh-My-Posh
    curl -s https://ohmyposh.dev/install.sh | bash -s
    mkdir -p "$HOME/.local/bin"; cd ~/.local/bin
    sudo mv oh-my-posh /usr/local/bin
    cd $dotdir
}

nonpkgdeps

# Backup current config
mkdir -p "$dotdir/backup/config/"

for backupdir in */; do
    backupdir=${backupdir%/}
    case "$backupdir" in
        dependencies|hyprland|release|archive|backup|icons|other|wallpapers)
            continue
            ;;
        *)
            if [[ -d "$HOME/.config/$backupdir" ]]; then
                cp -r "$HOME/.config/$backupdir" "$dotdir/backup/config/"
            fi
            ;;
    esac
done

for backupfile in .vimrc .p10k.zsh .zshrc; do
    if [[ -f "$HOME/$backupfile" ]]; then
        cp "$HOME/$backupfile" "$dotdir/backup/${file#.}"
    fi
done

# Backup hyprland config
clear
if [[ $hyprconfig -eq 0 ]]; then
    echo "I will ask you questions. If you don't use what I ask you about"
    echo "leave it blank. Make sure to specify FULL path (ex: /home/user/.config/dunst)"
    sleep 3.5
    echo ""
    
    for program in dunst hyprland rofi waybar; do
        read -p "Input your $program config path: " program_path
        if [[ -n "$program_path" && -e "$program_path" ]]; then
            cp -r "$program_path" "$dotdir/backup/config/"
        fi
    done
fi

# Initlize config
cd $dotdir
for dir in */; do
    dir=${dir%/}
    case "$dir" in
        dependencies|hyprland|release|archive|backup|icons|other|wallpapers)
            continue
            ;;
        *)
            echo "Applying config for $dir"
            stow -D "$dir" 2>/dev/null || true
            stow "$dir" --adopt
            ;;
    esac
done

cd $dotdir

# Install icons for hyprland & wallpapers
if [[ $hyprconfig -eq 0 ]]; then
    stow hyprland --adopt
    if [[ ! -d "/usr/share/icons/FontAwsome" ]]; then
        sudo mkdir -p /usr/share/icons/FontAwesome; icons="/usr/share/icons/FontAwesome/"
    fi
    sudo cp icons/* $icons
    mkdir -p $HOME/Pictures/Wallpapers; cp wallpapers/* $HOME/Pictures/Wallpapers
fi

# Install spotify
sudo cp other/spotify-notify /usr/local/bin

if [[ ! -d "$HOME/.config/systemd/user" ]]; then
    mkdir -p $HOME/.config/systemd/user/
fi

cd $dotdir
cp other/spotify-notify.service "$HOME/.config/systemd/user/"

systemctl --user daemon-reload; systemctl --user enable --now spotify-notify.service
systemctl --user enable spotify-notify.service; systemctl --user start spotify-notify.service


# Install Hyprland
if [[ $hyprinstall -eq 0 ]]; then
    if [[ ! -d "$HOME/Hyprland" ]]; then
        git clone --recursive https://github.com/hyprwm/Hyprland "$HOME/Hyprland"
    else
        git -C "$HOME/Hyprland" pull --force
    fi
    
    pushd "$HOME/Hyprland"
    mkdir -p build && cd build
    cmake -G Ninja ..
    sudo ninja install
    popd
fi

# Ly start
systemctl enable ly@tty1 || true
systemctl disable ly@tty2 || true
systemctl enable gettyy@tty2 || true
systemctl disable getty@tty1 || true

# Waybar module
rustup override set stable
rustup update stable
git clone https://github.com/coffebar/waybar-module-pacman-updates.git /tmp/waybar-module-pacman-updates
cd /tmp/waybar-module-pacman-updates && cargo build --release
mkdir -p ~/.local/bin
cp target/release/waybar-module-pacman-updates ~/.local/bin/
cd $HOME
rm -rf /tmp/waybar-module-pacman-updates 


# Options
cd $HOME
clear
read -p "Would you like to install the minegrub bootloader theme?: (y/n) " minegrub
read -p "Would you like to install Spotify add block?: (y/n) " spotx
read -p "Would you like to install Ly configuration?: (y'n) " ly

if [[ $minegrub == "Y" || $minegrub == "y" ]]; then
    git clone https://github.com/Lxtharia/double-minegrub-menu.git /tmp/double-minegrub-menu
    pushd /tmp/double-minegrub-menu
    sudo ./install.sh
    popd
fi

if [[ $ly == "y" || $ly == "Y" ]]; then
    sudo git clone https://github.com/clippyricer/ly-config.git /etc/ly
fi

if [[ $spotx == "y" || $spotx == "Y" ]]; then
    cd $HOME; bash <(curl -sSL https://spotx-official.github.io/run.sh)
fi

if [[ $hyprconfig -eq 0 ]]; then
    git clone https://codeberg.org/LGFae/awww.git /tmp/awww
    pushd /tmp/awww; cargo build --release
    sudo cp target/release/awww /usr/local/bin; sudo cp target/release/awww-daemon /usr/local/bin
    ./doc/gen.sh; sudo cp doc/generated* /usr/share/man
fi

clear
echo "Done!"
echo "To see effects close your terminal and open up kitty to see the effects"
