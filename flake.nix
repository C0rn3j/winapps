{
  description = "WinApps Nix packages & NixOS module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        formatter = pkgs.alejandra;

        packages.winapps = pkgs.callPackage ./packages/winapps {};
        packages.winapps-launcher = pkgs.callPackage ./packages/winapps-launcher {};
      }
    );
}
