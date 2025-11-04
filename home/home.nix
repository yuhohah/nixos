{ config, pkgs, unstable, ... }:

{
  home.username = "luan";
  home.homeDirectory = "/home/luan";

  wayland.windowManager.hyprland = {
  enable = true;
  systemd.enable = true;  # opcional, mas recomendado
  # xwayland.enable = true;  # se precisar de X11 apps
  };

  imports = [
    
    ./hyprland/appearance.nix
    ./hyprland/autostart.nix
    ./hyprland/keybinds.nix
    ./hyprland/monitors.nix
    ./waybar/config.nix
    ./alacritty/default.nix
    #./modules/apps/vscode.nix
    #./modules/apps/vesktop.nix
    #./modules/apps/kitty.nix

    
  ];



  home.stateVersion = "25.05";

  programs.git.enable = true;
  programs.zsh.enable = true;

}

