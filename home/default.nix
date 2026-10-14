{ ... }:
{
  imports = [
    ./common.nix

    # Desktop Environment (Hyprland)
    ./hyprland/default.nix
    ./hyprland/hypridle.nix
    ./hyprland/hyprlock.nix
    ./quickshell/default.nix
    ./mako/default.nix

    # Apps
    ./alacritty/default.nix
    ./satty/config.nix
    ./fastfetch/default.nix
    ./vicinae/default.nix
  ];
}
