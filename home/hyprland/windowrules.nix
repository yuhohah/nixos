{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    xwayland = {
      force_zero_scaling = true;
    };
    windowrulev2 = [
      # Fix for Steam resizing and menu issues in Hyprland
      "stayfocused, title:^()$,class:^(steam)$"
      "minsize 1 1, title:^()$,class:^(steam)$"
    ];
  };
}
