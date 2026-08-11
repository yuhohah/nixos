{ config, pkgs, inputs, ... }:
{
  imports = [
    ../common.nix

    # Desktop Environment (Hyprland)
    ../hyprland/appearance.nix
    ../hyprland/autostart.nix
    ../hyprland/keybinds.nix
    ../hyprland/monitors.nix
    ../hyprland/hypridle.nix
    ../hyprland/hyprlock.nix
    ../waybar/notebook.nix
    ../mako/default.nix
    
    # Apps
    ../alacritty/default.nix
    ../satty/config.nix
    ../fastfetch/default.nix
    ../vicinae/default.nix

    #scripts
    ../scripts/battery-alert.nix

    inputs.zen-browser.homeModules.twilight-official

  ];
}
