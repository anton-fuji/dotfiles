# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Plugins
plugins=( 
    git
    zsh-autosuggestions
)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

## Golang Settings
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:/usr/local/opt/mysql-client/bin:$PATH

## Starship Prompt
eval "$(starship init zsh)"

## Aliases
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
alias v='nvim'
alias tf='terraform'
alias d='docker'
alias dc='docker compose'
