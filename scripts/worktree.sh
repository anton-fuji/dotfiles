#!/bin/sh
set -eu
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
# WezTerm's noninteractive login shell can resolve an older /usr/local Zellij.
if [ "$(command -v zellij || true)" = /usr/local/bin/zellij ] && [ -x /opt/homebrew/bin/zellij ]; then
    PATH=/opt/homebrew/bin:$PATH
    export PATH
fi
source_dir=$script_dir/worktree
cache_dir=${XDG_CACHE_HOME:-"$HOME/.cache"}/dotfiles-worktree
fingerprint=$(shasum -a 256 "$source_dir/go.mod" "$source_dir"/*.go | shasum -a 256 | cut -c1-16)
binary=$cache_dir/worktree-$(uname -s)-$(uname -m)-$fingerprint
if [ ! -x "$binary" ]; then
    mkdir -p "$cache_dir"
    stage=$(mktemp -d "$cache_dir/.build.XXXXXXXX")
    trap 'rm -rf "$stage"' EXIT HUP INT TERM
    (cd "$source_dir" && GOTOOLCHAIN=local go build -trimpath -buildvcs=false -o "$stage/worktree" .)
    mv -f "$stage/worktree" "$binary"
    rmdir "$stage"
    trap - EXIT HUP INT TERM
fi
DOTFILES_CONFIG_ROOT=$(CDPATH= cd -- "$script_dir/.." && pwd -P)
export DOTFILES_CONFIG_ROOT
exec "$binary" "$@"
