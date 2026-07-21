{ ... }:

{
  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.bun/bin"
    "$HOME/tools/zig"
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    BUN_INSTALL = "$HOME/.bun";
    EZA_CONFIG_DIR = "$HOME/.config/eza";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    history = {
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
      ];
    };

    shellAliases = {
      g = "git";
      lg = "lazygit";
      ld = "lazydocker";
      ll = "eza -l --icons --header";
      la = "eza -la --icons";
      tree = "eza --icons -l -T -L 3";
      tree-a = "eza --icons -al -T -L 2";
      cp = "cp -i";
      rm = "rm -i";
      ls = "eza --icons --git";
      src = "source ~/.zshrc";
      path = "echo $PATH | tr ':' '\\n'";
      cat = "bat";
      clip = "pbcopy";
      gcc = "gcc-14";
      "g++" = "g++-14";
      sketchybar = "/opt/homebrew/bin/sketchybar";
      v = "nvim";
      nvcnf = "cd ~/.config/nvim";
      tf = "terraform";
      d = "docker";
      dc = "docker compose";
      lt = "eza -T -L 3 -a -I \"node_modules|.git|.cache\" --icons";
      ltl = "eza -T -L 3 -a -I \"node_modules|.git|.cache\" -l --icons";
    };

    initContent = ''
      typeset -U path PATH

      export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
      export CPLUS_INCLUDE_PATH="''${CPLUS_INCLUDE_PATH}:/opt/homebrew/include/"

      if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      if [ -f "$HOME/.cargo/env" ]; then
        . "$HOME/.cargo/env"
      fi

      if [ -d "$(go env GOPATH 2>/dev/null)/bin" ]; then
        path+=("$(go env GOPATH)/bin")
      fi

      if [ -s "$BUN_INSTALL/_bun" ]; then
        source "$BUN_INSTALL/_bun"
      fi

      if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
        . "$HOME/google-cloud-sdk/path.zsh.inc"
      fi

      if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
        . "$HOME/google-cloud-sdk/completion.zsh.inc"
      fi

      if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate zsh)"
      fi

      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }

      function gitmain() {
        git config --global user.name "Fuji"
        git config --global user.email "fujiji.entire1414@gmail.com"
      }

      zs() {
        local session
        session=$(zellij list-sessions | awk '{print $1}' | fzf --reverse --exit-0)

        if [[ -n "$session" ]]; then
          zellij attach "$session"
        fi
      }

      zellij_names_update() {
        if [[ -n $ZELLIJ ]]; then
          local full_path=$PWD
          local path_with_tilde=''${full_path/#$HOME/"~"}
          local dir_name=''${full_path##*/}

          if [[ $full_path == $HOME ]]; then
            dir_name="~"
          fi

          command nohup zellij action rename-tab -- "$dir_name" >/dev/null 2>&1
          command nohup zellij action rename-pane -- "$path_with_tilde" >/dev/null 2>&1
        fi
      }

      zellij_names_update
      chpwd_functions+=(zellij_names_update)

      fzf-file-edit() {
        local file
        file=$(fd --type f --hidden --follow --exclude .git |
          fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' \
              --header 'Select file to edit') &&
        ''${EDITOR:-nvim} "$file"
      }
      alias fz='fzf-file-edit'
      compdef g=git

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
          BUFFER="cd ''${dir}"
          zle accept-line
        fi
      }
      zle -N fzf-sd
      bindkey '^]' fzf-sd

      if [[ -z "$WEZTERM_EXECUTING" ]] && command -v fastfetch >/dev/null 2>&1; then
        export WEZTERM_EXECUTING=1
        fastfetch --config "$HOME/.config/fastfetch/config.json"
      fi

      [ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
    '';
  };
}
