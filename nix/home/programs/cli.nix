{ pkgs, ... }:

{
  # Starship
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # fzf
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultOptions = [
      "--height 60%"
      "--layout=reverse"
      "--border=rounded"
      "--info=inline"
      "--prompt='❯ '"
      "--pointer='▶'"
      "--marker='✓'"
      "--ansi"
      "--color='fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7'"
      "--color='fg+:#c0caf5,bg+:#283457,hl+:#7dcfff'"
      "--color='info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff'"
      "--color='marker:#9ece6a,spinner:#bb9af7,header:#7aa2f7'"
      "--color='border:#3b4261,label:#7aa2f7,query:#c0caf5'"
      "--color='preview-bg:#1f2335,preview-border:#3b4261'"
      "--bind='ctrl-/:toggle-preview'"
      "--bind='ctrl-u:preview-half-page-up'"
      "--bind='ctrl-d:preview-half-page-down'"
      "--preview-window='right:50%:border-left'"
    ];

    fileWidgetOptions = [
      "--walker-skip .git,node_modules,target,.cache"
      "--preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || tree -C {} 2>/dev/null || cat {}'"
      "--header 'CTRL-T: Files & Directories | CTRL-/: Toggle Preview'"
      "--bind 'ctrl-u:clear-query'"
    ];

    historyWidgetOptions = [
      "--preview 'echo {2..}'"
      "--preview-window down:3:wrap"
      "--header 'CTRL-R: Command History | CTRL-/: Toggle Preview'"
      "--color header:italic"
      "--bind 'ctrl-u:clear-query'"
    ];
  };


  # bat
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };

  # eza
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  # btop
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyo-night";
      theme_background = false;
    };
  };

}
