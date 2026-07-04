{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Fuji";
        email = "fujiji.entire1414@gmail.com";
      };

      init.defaultBranch = "main";
      merge.ff = false;
      pull.ff = "only";
      core.editor = "nvim";

      ghq.root = "/Users/fujimotoikki/MyDev";

      alias = {
        ad = "add";
        cm = "commit -m";
        s = "status";
        ss = "status -s";
        rb = "rebase";
        st = "stash";
        sh = "show";
        ps = "push";
        pl = "pull";
        rst = "reset";
        br = "branch";
        brd = "branch -d";
        co = "checkout";
        cob = "checkout -b";
        l = "log";
        l1 = "log -1";
        l2 = "log -2";
        l3 = "log -3";
        lo = "log --oneline";
        alias = "!git config --get-regexp '^alias\\\\.' | sed 's/alias\\\\.\\\\([^ ]*\\\\) \\\\(.*\\\\)/\\\\1\\\\t => \\\\2/' | sort";
        gr = "log --graph --date=short --decorate=short --pretty=format:'%Cgreen%h %Creset%cd %Cblue%cn %Cred%d %Creset%s'";
        fco = "!git branch -a | cut -c 3- | sed 's|remotes/origin/||' | sort | uniq | fzf --preview \"git log --color=always --pretty=format:'%h %cd %s' --date=format:'%Y-%m-%d %H:%M' {}\" | xargs git checkout";
      };
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
