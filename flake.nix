{
  description = "A Flake to download dependencies";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system:
        f (import nixpkgs { inherit system; })
      );
    in {
      packages = forAllSystems (pkgs: {
        default = pkgs.symlinkJoin {
          name = "deps";
          paths = [
            pkgs.jq
            pkgs.python315
            pkgs.zip
            pkgs.unzip
            pkgs.tmux
            pkgs.fastfetch
          ];
        };
      });

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          # This points to 'true', which does nothing. 
          # But to get here, Nix MUST download everything in 'packages.default' first.
          program = "${pkgs.coreutils}/bin/true";
        };
      });
    };
}
