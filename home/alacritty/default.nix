{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [ "-l" ];
      };
      font = {
        normal.family = "JetBrainsMono Nerd Font Mono";
        #style = "Medium";
        size = 11.0;
      };
    };
  };
}