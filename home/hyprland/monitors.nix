{ config, pkgs, osConfig, lib, ... }:

let
  hostname = osConfig.networking.hostName;

  nixos-btw = ''
    -- Monitor config for nixos-btw
    hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@144", position = "0x0", scale = "1" })
    hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@74.973", position = "-1920x0", scale = "1" })
    
    -- Workspace config for nixos-btw
    hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1" })
    hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-2" })
    hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1" })
    hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-2" })
  '';

  arrow = ''
    -- Monitor config for arrow
    hl.monitor({ output = "eDP-1", mode = "1920x1080", position = "0x0", scale = "1" })
    hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@144", position = "1920x0", scale = "1" })
    
    -- Workspace config for arrow
    hl.workspace_rule({ workspace = "1", monitor = "eDP-1" })
  '';

  monitorConfig = if hostname == "arrow" then arrow else nixos-btw;

in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    extraConfig = monitorConfig;
  };
}