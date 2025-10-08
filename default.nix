{
  pkgs ? import <nixpkgs> {},
  system ? pkgs.stdenv.hostPlatform.system,
}: let
  mkVicinae = name: entry: let
    variant = (builtins.fromJSON (builtins.readFile ./sources.json)).${entry}.${system};
  in
    pkgs.callPackage ./package.nix {
      inherit name variant;
    };
in rec {
  git = mkVicinae "git" "git";
  stable = mkVicinae "stable" "stable";

  default = stable;
}
