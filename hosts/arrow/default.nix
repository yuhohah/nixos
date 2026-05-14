{ config, pkgs, ... }:

{
  networking.hostName = "arrow";
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
  ];
  
  my.system.core.enable = true;
  my.system.networking.enable = true;
  my.system.audio.enable = true;
  my.system.hyprland.enable = true;
  my.system.greetd.enable = true;
  my.system.users.enable = true;
  my.system.gvfs.enable = true;
  
  my.apps.laptop.enable = true;
  my.apps.core.enable = true;
  my.apps.media.enable = true;
  my.apps.dev.enable = true;
  my.apps.browsers.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  hardware.enableRedistributableFirmware = true;
  services.acpid.enable = true;
}
