set shell := ["zsh", "-cu"]

host := "fujimotoikkinoMacBook-Air-2"
flake := ".#" + host

default:
    @just --list

fmt:
    nixpkgs-fmt flake.nix nix/**/*.nix

check:
    nix flake check --no-build --no-write-lock-file

eval:
    nix eval --no-write-lock-file {{flake}}.config.system.build.toplevel.drvPath

dry-run:
    nix build --dry-run --no-write-lock-file {{flake}}.config.system.build.toplevel

build:
    nix build {{flake}}.config.system.build.toplevel

switch:
    darwin-rebuild switch --flake {{flake}}

update:
    nix flake update
