let
  flake = builtins.getFlake "github:numtide/treefmt-nix";
  pkgs = import (builtins.getFlake "github:nixos/nixpkgs/nixos-unstable") {
    system = builtins.currentSystem;
  };
  wrapper = flake.lib.mkWrapper pkgs ./packages/treefmt.nix;
in
wrapper
