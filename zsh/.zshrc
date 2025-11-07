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
