#!/usr/bin/env bash
# Claude Code status line (Tokyo Night Night)
# (model)(session)  dir · branch● · ctx ▰▰▱▱ % · $cost · +add -del
input=$(cat)
j() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

model=$(j '.model.display_name')
dir=$(j '.workspace.current_dir'); [ -z "$dir" ] && dir=$(j '.cwd')
ctx=$(j '.context_window.used_percentage')
cost=$(j '.cost.total_cost_usd')
added=$(j '.cost.total_lines_added')
removed=$(j '.cost.total_lines_removed')
transcript=$(j '.transcript_path')

# セッション名: 入力 JSON → /rename のタイトル → 自動生成タイトル
session=$(j '.session_name')
if [ -z "$session" ] && [ -f "$transcript" ]; then
  session=$(grep -oE '"customTitle":"[^"]*"' "$transcript" 2>/dev/null | tail -1 | cut -d'"' -f4)
  [ -z "$session" ] && session=$(grep -oE '"aiTitle":"[^"]*"' "$transcript" 2>/dev/null | tail -1 | cut -d'"' -f4)
fi
[ ${#session} -gt 32 ] && session="${session:0:31}…"

# Tokyo Night Night palette
BG='26;27;38'           # #1a1b26
BG_HL='41;46;66'        # #292e42
FG='192;202;245'        # #c0caf5
MUTED='115;122;162'    # #737aa2
GUTTER='59;66;97'      # #3b4261
BLUE='122;162;247'      # #7aa2f7
CYAN='125;207;255'      # #7dcfff
PURPLE='187;154;247'    # #bb9af7
GREEN='158;206;106'     # #9ece6a
YELLOW='224;175;104'    # #e0af68
ORANGE='255;158;100'    # #ff9e64
RED='247;118;142'       # #f7768e

fg() { printf '\033[38;2;%sm' "$1"; }
bg() { printf '\033[48;2;%sm' "$1"; }
R=$'\033[0m'
CAP_L=$'\xee\x82\xb6'   # U+E0B6
CAP_R=$'\xee\x82\xb4'   # U+E0B4
ARROW=$'\xee\x82\xb0'   # U+E0B0
I_DIR=$'\xef\x81\xbc'   # U+F07C
I_GIT=$'\xee\x82\xa0'   # U+E0A0
SEP=" $(fg "$MUTED")·$R "

# ── 左のピル: model → session ──
out="$(fg "$BG")${CAP_L}$R$(bg "$BG")$(fg "$BLUE")\033[1m 󰚩 ${model:-?} $R"
if [ -n "$session" ]; then
  out+="$(bg "$BG_HL")$(fg "$BG")${ARROW}$R$(bg "$BG_HL")$(fg "$PURPLE") 󰆍 ${session} $R$(fg "$BG_HL")${CAP_R}$R"
else
  out+="$(fg "$BG")${CAP_R}$R"
fi

# ── ディレクトリ ──
short="$dir"; case "$dir" in "$HOME"*) short="~${dir#"$HOME"}";; esac
[ -n "$dir" ] && out+="  $(fg "$CYAN")${I_DIR} $(fg "$FG")${short}$R"

# ── git ──
if [ -n "$dir" ] && branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null) && [ -n "$branch" ]; then
  dirty=""
  [ -n "$(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null | head -1)" ] && dirty=" $(fg "$ORANGE")●"
  out+="${SEP}$(fg "$PURPLE")${I_GIT} ${branch}${dirty}$R"
fi

# ── context バー ──
if [ -n "$ctx" ]; then
  pct=${ctx%.*}
  color=$GREEN; [ "$pct" -ge 50 ] && color=$YELLOW; [ "$pct" -ge 80 ] && color=$RED
  filled=$(( (pct + 5) / 10 )); [ "$filled" -gt 10 ] && filled=10
  bar=""; for ((i = 0; i < 10; i++)); do
    if [ "$i" -lt "$filled" ]; then bar+="$(fg "$color")▰"; else bar+="$(fg "$GUTTER")▰"; fi
  done
  out+="${SEP}${bar} $(fg "$color")${pct}%$R"
fi

# ── コスト・変更行 ──
[ -n "$cost" ] && out+="${SEP}$(fg "$YELLOW")\$$(printf '%.2f' "$cost")$R"
if [ -n "$added$removed" ] && [ "${added:-0}${removed:-0}" != "00" ]; then
  out+="${SEP}$(fg "$GREEN")+${added:-0} $(fg "$RED")-${removed:-0}$R"
fi

printf '%b' "$out"
