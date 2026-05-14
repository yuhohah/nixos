{ config, lib, pkgs, ... }:

{
  options.my.system.hyprland.enable = lib.mkEnableOption "Hyprland System Config";

  config = lib.mkIf config.my.system.hyprland.enable {
    programs.hyprland.enable = true;
    programs.hyprland.xwayland.enable = true;
    programs.hyprland.withUWSM = true;
  };
}
