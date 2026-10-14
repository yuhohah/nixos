{ pkgs, ... }:

{
  networking.hostName = "arrow";
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
  ];

  generationTracker.configDir = "/home/luan/Configuration/nixos";
  
  # Sistema base
  my.system.core.enable = true;
  my.system.networking.enable = true;
  my.system.audio.enable = true;
  my.system.hyprland.enable = true;
  my.system.greetd.enable = true;
  my.system.users.enable = true;
  my.system.gvfs.enable = true;
  
  # Role de hardware e usuário
  my.roles.laptop.enable = true;
  
  # Aplicativos
  my.apps.core.enable = true;
  my.apps.media.enable = true;
  my.apps.dev.enable = true;
  my.apps.browsers.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;
}
