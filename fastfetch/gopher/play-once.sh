#!/bin/sh
set -eu
[ "${FASTFETCH_GOPHER_SKIP_ANIMATION:-${FASTFETCH_KOI_SKIP_ANIMATION:-0}}" = 1 ] && exit 0
[ -t 1 ] || exit 1
asset_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cleanup() { printf '\033[0m\033[?25h\033[2J\033[H'; }
trap cleanup EXIT HUP INT TERM
printf '\033[?25l\033[2J\033[H'
while read -r frame duration; do
  case "$frame" in frame-*.ansi) ;; *) exit 1 ;; esac
  [ -s "$asset_dir/animation/$frame" ] || exit 1
  printf '\033[H'
  cat "$asset_dir/animation/$frame"
  sleep "$duration"
done < "$asset_dir/animation/timing.tsv"
cleanup
trap - EXIT HUP INT TERM
