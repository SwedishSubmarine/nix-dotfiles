{ ... }:
{
  programs.git = {
    enable = true;
    userEmail = "emily.jo.tiberg@gmail.com";
    userName = "Emily Tiberg";
    aliases = {
      s = "status";
      lg = ''log --oneline --graph --decorate --pretty=format:"%C(cyan)%h\ %ad%Cred%d \%Creset%s%Cblue" --date=short'';
    };
    ignores = ["**/.DS_Store" ];
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nvim";
      merge.autostash = true;
    };
  };
}
