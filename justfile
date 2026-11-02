set shell := ["zsh", "-cu"]

# ユーザー名は flake.nix が環境変数から読むため、評価には --impure が必要。
host := "macbook"
flake := ".#" + host
system := ".#darwinConfigurations." + host

default:
    @just --list

fmt:
    nixpkgs-fmt flake.nix nix/**/*.nix

check:
    nix flake check --impure --no-build --no-write-lock-file

eval:
    nix eval --impure --no-write-lock-file {{system}}.config.system.build.toplevel.drvPath

dry-run:
    nix build --impure --dry-run --no-write-lock-file {{system}}.config.system.build.toplevel

build:
    nix build --impure {{system}}.config.system.build.toplevel

switch:
    darwin-rebuild switch --impure --flake {{flake}}

update:
    nix flake update
