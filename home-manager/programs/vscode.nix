{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        ms-vsliveshare.vsliveshare
      ];
    };
  };
  catppuccin.vscode.profiles.default.enable = true;
}
