{ config, pkgs, osConfig, lib, ... }:

let
  hostname = osConfig.networking.hostName;

  # Configuração Padrão (Desktop/PC)
  nixos-btw = {
    monitor = [
      "HDMI-A-1,1920x1080@144,0x0,1"
      "HDMI-A-2,1920x1080@74.973,1920x0,1"
    ];
    workspace = [
      "1, monitor:HDMI-A-1"
      "2, monitor:HDMI-A-2"
      "3, monitor:HDMI-A-1"
      "4, monitor:HDMI-A-2"
    ];
  };

  # Configuração do Notebook (Arrow)
  arrow = {
    monitor = [
      #,preferred,auto,1" # Auto-detectar com scale 1
      "eDP-1, 1920x1080, 0x0, 1"
      "HDMI-A-1,1920x1080@144,1920x0,1"
    ];
    workspace = [
      "1, monitor:eDP-1"
      #"2, monitor:eDP-1"
    ];
  };

  # Seleciona a config baseada no hostname
  monitorConfig = if hostname == "arrow" then arrow else nixos-btw;

in
{
  wayland.windowManager.hyprland.settings = {
    monitor = monitorConfig.monitor;
    workspace = monitorConfig.workspace;
  };
}