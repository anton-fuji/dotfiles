{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Fuji";
    userEmail = "164746053+anton-fuji@users.noreply.github.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "nvim";
    };

    # delta (diff viewer)
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
      };
    };

  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
    };
  };
}

