#!/bin/bash

LOG_FILE="log.txt"

# Comment this for ouput loggin
LOGGING_ACTIVE=1

if [ -z "$LOGGING_ACTIVE" ]; then
    # Set the flag and re-run this script using the 'script' command
    rm log.txt
    export LOGGING_ACTIVE=1
    exec script -q -c "$0 $*" "$LOG_FILE"
    exit
fi

#set -e
setupcache="$HOME/.cache/setup.cache"
scriptdir=$(pwd)
hyprinstall=1
hyprconfig=1
paruinstall="NO"
mkdir -p "$HOME/.cache/"
if [[ ! -f "$HOME/.cache/setup.cache" ]]; then
    cp "../setup.cache" "$HOME/.cache/setup.cache"
fi

# Spinner function
spinner() {
    local pid=$1
    local delay=0.2
    local spinstr='|/-\'
    
    # Capture start time
    local start_time=$SECONDS
    
    # Hide cursor
    tput civis 

    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\e[0;36m [%c] " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b" # Clears the "[x] "
    done

    # Calculate total time
    local total_seconds=$(( SECONDS - start_time ))
    
    # Convert to minutes and seconds
    local m=$(( total_seconds / 60 ))
    local s=$(( total_seconds % 60 ))

    # Restore cursor
    tput cnorm

    # Logic to print either "1m 10s" or just "10s"
    if [ $m -gt 0 ]; then
        echo -e "\e[1;32mDone in ${m}m ${s}s!\e[0m \n"
    else
        echo -e "\e[1;32mDone in ${s}s!\e[0m \n"
    fi
}


# Update pkgs and install script deps
sudo pacman -Syu --noconfirm
scriptdepsst=$(sed -n '1p' $setupcache)
if [[ $scriptdepsst -eq 0 ]]; then
    sudo pacman -S gum base-devel python3 python-pip --noconfirm
    pip install chardet lib3 datetime requests statistics urllib3 dulwich --break-system-packages
    sed -i '1c\1' $setupcache
fi
# Install paru
parustatus=$(sed -n '2p' $setupcache)
if [[ ! -x /usr/bin/paru || $parustatus -eq 0 ]]; then
    pushd $HOME; git clone https://aur.archlinux.org/paru.git
    cd paru/ && makepkg -si --noconfirm; popd
    sed -i '2c\1' $setupcache
    paruinstall="YES"
fi

# Install hyprland deps
clear
if gum confirm "Would you like to install hyprland/update?"; then
    hyprinstall=1
    aurdeps=$(cat dependencies/aur-arch.txt)
    hyprdepsst=$(sed -n '3p' $setupcache)
    if [[ $hyprdepsst -eq 0 ]]; then
        paru -S $aurdeps --noconfirm
        paruinstall="YES"
        sed -i '3c\0' $setupcache
    else
        paru -Syu --noconfirm
    fi
else
    hyprinstall=0
fi



# Remove packaged rust
if [[ $paruinstall == "YES"  ]]; then
  paru -R rust --noconfirm || true
fi

# Install basic deps
archdeps=$(cat dependencies/basic-arch.txt)
archdepsst=$(sed -n '4p' $setupcache)
if [[ $archdepsst -eq 0 ]]; then
    sudo pacman -S $archdeps --noconfirm --needed
    sed -i '4c\0' $setupcache
fi

# Install non pkg dependencies
nonpkgdeps() {
    # Rust & Other & Fonts
    nonpkgdepsst=$(sed -n '5p' $setupcache)
    if [[ $nonpkgdepsst -eq 0 ]]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        curl -LO --output-dir ../ https://github.com/clippyricer/dotfiles/releases/download/v0.1.0/assets.tar; cd ..
        tar -xvf assets.tar; rm -rf assets.tar
    
        fontdir="/usr/share/fonts/JetBrainsMono/"
        if [[ ! -d "/usr/share/fonts/JetBrainsMono" ]]; then
            sudo mkdir -p /usr/share/fonts/JetBrainsMono/
        fi

        curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
        sudo tar -xvf JetBrainsMono.tar.xz -C $fontdir; rm -rf JetBrainsMono.tar.xz
        cd $fontdir; sudo rm -rf *.md *.txt
        cd $scriptdir
        fc-cache -frv


        # Oh-My-Posh
        curl -s https://ohmyposh.dev/install.sh | bash -s
        cd $scriptdir
    fi
}

nonpkgdeps

# Backup current config
mkdir -p "../backup/config/"
cd ..

for backupdir in */; do
    backupdir=${backupdir%/}
    case "$backupdir" in
        dependencies|hyprland|release|archive|backup|icons|other|wallpapers)
            continue
            ;;
        *)
            if [[ -d "$HOME/.config/$backupdir" ]]; then
                cp -r "$HOME/.config/$backupdir" "./backup/config/"
            fi
            ;;
    esac
done

for backupfile in .vimrc .p10k.zsh .zshrc; do
    if [[ -f "$HOME/$backupfile" ]]; then
        cp "$HOME/$backupfile" "./backup/${file#.}"
    fi
done

# Backup hyprland config
clear
if [[ $hyprconfig -eq 1 ]]; then
    echo "I will ask you questions. If you don't use what I ask you about"
    echo "leave it blank. Make sure to specify FULL path (ex: /home/user/.config/dunst)"
    sleep 3.5
    echo ""
    
    for program in dunst hyprland rofi waybar; do
        read -p "Input your $program config path: " program_path
        if [[ -n "$program_path" && -e "$program_path" ]]; then
            cp -r "$program_path" ".//backup/config/"
        fi
    done
fi

# Initlize config
cd $scriptdir; cd ..
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

cd $scriptdir; cd ..

# Install icons for hyprland & wallpapers
if [[ $hyprconfig -eq 1 ]]; then
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

cd $scriptdir; cd ..
cp other/spotify-notify.service "$HOME/.config/systemd/user/"

systemctl --user daemon-reload; systemctl --user enable --now spotify-notify.service
systemctl --user enable spotify-notify.service; systemctl --user start spotify-notify.service


# Install Hyprland
if [[ $hyprinstall -eq 1 ]]; then
    if [[ ! -d "$HOME/Hyprland" ]]; then
        git clone --recursive https://github.com/hyprwm/Hyprland "$HOME/Hyprland"

        pushd "$HOME/Hyprland"
        mkdir -p build && cd build
        cmake -G Ninja ..
        sudo ninja install
        popd
    else
        git -C "$HOME/Hyprland" pull --force
    fi    
fi

# Ly start
systemctl enable ly@tty1 || true
systemctl disable ly@tty2 || true
systemctl enable getty@tty2 || true
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

if [[ $hyprconfig -eq 1 ]]; then
    git clone https://codeberg.org/LGFae/awww.git /tmp/awww
    pushd /tmp/awww; cargo build --release
    sudo cp target/release/awww /usr/local/bin; sudo cp target/release/awww-daemon /usr/local/bin
    ./doc/gen.sh; sudo cp doc/generated* /usr/share/man
fi

clear
echo "Done!"
echo "To see effects close your terminal and open up kitty to see the effects"
