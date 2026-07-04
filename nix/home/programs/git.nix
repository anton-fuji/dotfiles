{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Fuji";
        email = "164746053+anton-fuji@users.noreply.github.com";
      };

      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "nvim";
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;

      options = {
        navigate = true;
        "line-numbers" = true;
        "side-by-side" = true;
      };
  };
}
