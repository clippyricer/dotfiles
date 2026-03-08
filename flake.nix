{
  description = "Flake for dotfiles for nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        jq
        libnotify
        tmux
        zip
        python3
        python3Packages.pip
        python3Packages.requests
        nerd-fonts.jetbrains-mono
        font-awesome
        scdoc
        unzip
        fastfetch
        eza
        yazi
        git
        cmatrix
        glow
        zsh
        zoxide
        fzf
        vim
        kitty
        ripgrep
        fd
        stow
        curl
        spotify
        rofi
        dunst
        playerctl
        ffmpeg_7
        btop
        xdg-desktop-portal
        pipewire
        pamixer
        wireplumber
        waybar
        alsa-utils
        brightnessctl
        ly
        oh-my-posh
        stow
        gum
        ninja
        cmake
        meson
        jetbrains-mono
        tree
        killall
      ];
    };
  };
}
