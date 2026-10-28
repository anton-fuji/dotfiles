#!/bin/sh
set -u

# GUI-launched WezTerm may not inherit Homebrew's PATH from the login shell.
PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"
export PATH

fastfetch_config="$HOME/.config/fastfetch/config.json"
gopher_dir="$HOME/.config/fastfetch/gopher"
fastfetch_bin=$(command -v fastfetch 2>/dev/null || true)

run_existing_fastfetch() {
  if [ -n "$fastfetch_bin" ]; then
    "$fastfetch_bin" --config "$fastfetch_config" || true
  fi
}

start_shell() {
  export WEZTERM_EXECUTING=1
  exec /bin/zsh -l
}

if [ -z "$fastfetch_bin" ] || [ ! -r "$fastfetch_config" ]; then
  # Let the existing .zshrc Fastfetch block run when the wrapper cannot.
  unset WEZTERM_EXECUTING
  exec /bin/zsh -l
fi

if ! "$gopher_dir/play-once.sh"; then
  run_existing_fastfetch
  start_shell
fi

if ! "$fastfetch_bin" \
  --config "$fastfetch_config" \
  --file "$gopher_dir/fastfetch-gopher.txt" \
  --logo-color-1 '#FAFAFC' \
  --logo-color-2 '#94CDDF' \
  --logo-color-3 '#739BBA' \
  --logo-color-4 '#C5B4AF' \
  --logo-color-5 '#204866'; then
  run_existing_fastfetch
fi

start_shell
