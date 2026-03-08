{
  description = "A Flake providing everything needed";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system:
        f {
          pkgs = import nixpkgs { inherit system; };
          system = system;
        }
      );
    in {
      packages = forAllSystems ({ pkgs, ... }: {
        default = pkgs.buildEnv {
          name = "dependencies";
          paths = [
            pkgs.jq
            pkgs.dunst
            pkgs.zip
            pkgs.unzip
            pkgs.tmux
            pkgs.python315
          ];
        };
      });
    };
}
