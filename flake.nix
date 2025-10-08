{
  description = "vicinae-bin flake delegating to vicinae’s flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    git.url = "github:vicinaehq/vicinae";
    stable.url = "github:vicinaehq/vicinae?ref=v0.14.2";
  };

  outputs = { self, nixpkgs, git, stable, ... }:
    {
      packages = {
        x86_64-linux = {
          git = git.packages.x86_64-linux.default;
          latest = git.packages.x86_64-linux.default;
          stable = stable.packages.x86_64-linux.default;
          default = git.packages.x86_64-linux.default;
        };
      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.latest;
    };
}
