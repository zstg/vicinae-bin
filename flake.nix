{
  description = "Vicinae-bin flake with git and stable outputs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    vicinae-src = {
      url = "github:vicinaehq/vicinae"; # Vicinae repository for git source
      # For stable tarball version we use fetchTarball in package definition below
    };
  };

  outputs = { self, nixpkgs, home-manager, vicinae-src, ... }@inputs:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forSystem = system: let
        pkgs = import nixpkgs { inherit system; };
        homeModules = import "${vicinae-src}/modules/home-manager" { inherit pkgs; };
        
        # Package builds
        gitVicinae = pkgs.stdenv.mkDerivation {
          pname = "vicinae-git";
          version = "unstable";

          src = inputs.vicinae-src;

          buildInputs = with pkgs; [
            cmake
            ninja
            nodejs_latest
            kdePackages.qtbase
            kdePackages.qtsvg
            gcc_latest
            protobuf
            cmark-gfm
            kdePackages.layer-shell-qt
            libqalculate
            minizip-ng
            kdePackages.qtkeychain
            rapidfuzz-cpp
            ccache
            mold
          ];

          buildPhase = ''
            mkdir build
            cd build
            cmake .. -DCMAKE_BUILD_TYPE=Release -DLTO=ON -DNOSTRIP=OFF
            make host-optimized
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp build/vicinae $out/bin/
          '';
        };

        stableVicinae = pkgs.stdenv.mkDerivation {
          pname = "vicinae-stable";
          version = "latest";

          src = pkgs.fetchTarball {
            url = "https://github.com/vicinaehq/vicinae/releases/latest/download/vicinae.tar.gz";
            sha256 = "0000000000000000000000000000000000000000000000000000"; # Replace with actual hash
          };

          buildInputs = with pkgs; [             cmake
            ninja
            nodejs_latest
            kdePackages.qtbase
            kdePackages.qtsvg
            gcc_latest
            protobuf
            cmark-gfm
            kdePackages.layer-shell-qt
            libqalculate
            minizip-ng
            kdePackages.qtkeychain
            rapidfuzz-cpp
            ccache
            mold ];

          buildPhase = ''
            mkdir build
            cd build
            cmake .. -DCMAKE_BUILD_TYPE=Release
            make
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp build/vicinae $out/bin/
          '';
        };
      in
      {
        packages = {
          git = gitVicinae;
          stable = stableVicinae;
        };

        homeModules.vicinae = homeModules; # reuse vicinae home-manager module here
      };

    in
    {
      # Expose packages under each system
      packages = builtins.listToAttrs (map (system: {
        name = system;
        value = forSystem system;
      }) systems);

      # Expose home-manager modules
      homeModules = forSystem systems[0].homeModules; # example: expose for first system
    };
}
