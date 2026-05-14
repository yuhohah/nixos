{ config, pkgs, ... }:

{
  networking.hostName = "arrow";
  imports = [
    ./hosts/arrow/hardware-configuration.nix
    
    ./modules/system/networking.nix

    ./modules/apps/laptop.nix
  ];
  
  # Kernel mais recente
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  hardware.enableRedistributableFirmware = true;
  services.acpid.enable = true;

  networking.networkmanager.enable = true;
  
}
