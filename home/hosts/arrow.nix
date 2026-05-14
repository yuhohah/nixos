{ config, pkgs, ... }:
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
    ../waybar/config.nix
    ../mako/default.nix
    
    # Apps
    ../alacritty/default.nix
    # ../vesktop/config.nix # Desativado no laptop por padrão, descomente se quiser
    ../satty/config.nix
    ../fastfetch/default.nix
    ../vicinae/default.nix
  ];
}
