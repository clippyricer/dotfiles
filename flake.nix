{
  description = "A Flake to strictly download dependencies";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system:
        f (import nixpkgs { inherit system; })
      );
    in {
      # 1. This defines the bundle of packages
      packages = forAllSystems (pkgs: {
        default = pkgs.symlinkJoin {
          name = "my-deps";
          paths = [
            pkgs.jq
            pkgs.python3 # Use python3 to grab the latest stable Python
            pkgs.zip
            pkgs.unzip
            pkgs.tmux
            pkgs.fastfetch
          ];
        };
      });

      # 2. This runs when you type 'nix run .'
      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          # We create a tiny script that references the package bundle.
          # Because the bundle is referenced here, Nix MUST download it all.
          program = "${pkgs.writeShellScriptBin "trigger-download" ''
            # Force Nix to realize (download/build) the dependencies:
            # ${self.packages.${pkgs.system}.default}
            echo "Dependencies successfully downloaded to the Nix store!"
          ''}/bin/trigger-download";
        };
      });
    };
}
