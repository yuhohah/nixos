{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font Mono 11";
      padding = "15,20";
      margin = "12";
      anchor = "top-right";
      width = 380;
      height = 160;
      outer-margin = "10";

      border-size = 2;
      border-radius = 16;

      background-color = "#1e1e2ea8";
      border-color = "#cba6f759";
      text-color = "#cdd6f4";
      progress-color = "over #cba6f733";      

      icons = true;
      icon-path = "${pkgs.adwaita-icon-theme}/share/icons/Adwaita";
      max-icon-size = 48;

      default-timeout = 4000;
      ignore-timeout = true;
      layer = "overlay";

      "urgency=high" = {
        border-color = "#f38ba8cc";
        default-timeout = 0;
      };

      "urgency=low" = {
        border-color = "#45475a80";
        default-timeout = 2500;
      };
      
      "mode=do-not-disturb" = {
        invisible = true;
      };
    };
  };
}