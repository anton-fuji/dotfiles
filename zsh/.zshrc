# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi


# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

#Setting zsh-autosuggestions
plugins=(
    git
    zsh-autosuggestions
)


source $ZSH/oh-my-zsh.sh

# export MANPATH="/usr/local/man:$MANPATH"

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export EZA_CONFIG_DIR="$HOME/.config/eza"

##Setting Golang
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
export PATH="/usr/local/opt/mysql-client/bin:$PATH"

## Starship
eval "$(starship init zsh)"

## Mise Setup
eval "$(mise activate bash)"

## Eza Theme
export EZA_CONFIG_DIR="$HOME/.config/eza"


##Setting Alias
alias g='git'
compdef g=git

alias ll='ls -la'
alias cp='cp -i'
alias rm='rm -i'
alias ls='ls --color=auto'
alias src='source ~/.zshrc'
alias path="echo $PATH | tr ':' '\n'"
alias cat='bat'
alias clip='pbcopy'
alias gcc='gcc-14'
alias g++='g++-14'

### Neovim
alias v='nvim'
alias nvcnf='cd ~/.config/nvim'

### terraform
alias tf='terraform'

### docker
alias d='docker'
alias dc='docker compose'

# Setup Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Zellij Session exchange func
zs() {
  local session
  session=$(zellij list-sessions | awk '{print $1}' | fzf --reverse --exit-0)

  if [[ -n "$session" ]]; then
    zellij attach "$session"
  fi
}

## pane, tab settings
zellij_names_update() {
    if [[ -n $ZELLIJ ]]; then
        local full_path=$PWD
        local path_with_tilde=${full_path/#$HOME/"~"}

        local dir_name=${full_path##*/}
        if [[ $full_path == $HOME ]]; then
            dir_name="~"
        fi

        command nohup zellij action rename-tab -- "$dir_name" >/dev/null 2>&1
        command nohup zellij action rename-pane -- "$path_with_tilde" >/dev/null 2>&1
    fi
}

zellij_names_update
chpwd_functions+=(zellij_names_update)

# fzf Config
export FZF_DEFAULT_OPTS="
  --height 60%
  --layout=reverse
  --border=rounded
  --info=inline
  --prompt='❯ '
  --pointer='▶'
  --marker='✓'
  --ansi
  --color='fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7'
  --color='fg+:#c0caf5,bg+:#283457,hl+:#7dcfff'
  --color='info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff'
  --color='marker:#9ece6a,spinner:#bb9af7,header:#7aa2f7'
  --color='border:#3b4261,label:#7aa2f7,query:#c0caf5'
  --color='preview-bg:#1f2335,preview-border:#3b4261'
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-u:preview-half-page-up'
  --bind='ctrl-d:preview-half-page-down'
  --preview-window='right:50%:border-left'
"

# ファイル/ディレクトリ検索
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target,.cache
  --preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || tree -C {} 2>/dev/null || cat {}'
  --header 'CTRL-T: Files & Directories | CTRL-/: Toggle Preview'
  --bind 'ctrl-u:clear-query'
  --preview-window='right:50%:border-left'
"

# コマンド履歴検索
export FZF_CTRL_R_OPTS="
  --preview 'echo {2..}'
  --preview-window down:3:wrap
  --header 'CTRL-R: Command History | CTRL-/: Toggle Preview'
  --color header:italic
  --bind 'ctrl-u:clear-query'
  --preview-window='right:50%:border-left'
"

export FZF_COMPLETION_TRIGGER='**'

export FZF_COMPLETION_OPTS='
  --border
  --info=inline
  --preview-window=right:50%:border-left
'

fzf-file-edit() {
  local file
  file=$(fd --type f --hidden --follow --exclude .git |
         fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' \
             --header 'Select file to edit') &&
  ${EDITOR:-nvim} "$file"
}
alias fz='fzf-file-edit'

source <(fzf --zsh)

# ghq + fzf
function fzf-sd() {
  local dir=$(ghq list -p | fzf \
    --prompt="Repositories > " \
    --preview '
      if [ -d {} ]; then
        eza --icons -T -L 3 {} 2>/dev/null
      else
        bat --color=always --style=numbers {} 2>/dev/null || cat {}
      fi
    ' \
    --bind "ctrl-/:toggle-preview"
  )

  if [ -n "$dir" ]; then
    BUFFER="cd ${dir}"
    zle accept-line
  fi
}
zle -N fzf-sd
bindkey '^]' fzf-sd

# Setup Ascii
if [[ -z "$WEZTERM_EXECUTING" ]]; then
  export WEZTERM_EXECUTING=1
  fastfetch --config "$HOME/.config/fastfetch/config.json"
fi
