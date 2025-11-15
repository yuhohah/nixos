{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell = {
        program = "zsh";
        args = [ "-c" "exec zsh" ];
      };
      font = {
        normal.family = "JetBrainsMono Nerd Font Mono";
        #style = "Medium";
        size = 11.0;
      };
    };
  };
}