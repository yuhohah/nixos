{ config, lib, pkgs, ... }:

{
  options.my.system.hyprland.enable = lib.mkEnableOption "Hyprland System Config";

  config = lib.mkIf config.my.system.hyprland.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };

    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}
