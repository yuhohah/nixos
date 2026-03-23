{ config, pkgs, ... }:

{
  networking.hostName = "arrow";
  imports = [
    ./hardware-arrow.nix
    
    ./modules/system/networking.nix
    ./modules/system/audio.nix
    ./modules/system/hyprland.nix
    ./modules/system/greetd.nix
    #./modules/system/gaming.nix
    ./modules/system/users.nix
    ./modules/system/gvfs.nix
    ./modules/system/logind.nix # Notebook specific

    ./modules/apps/laptop.nix
    ./modules/apps/core.nix
    ./modules/apps/media.nix
    ./modules/apps/dev.nix
    ./modules/apps/browsers.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.nameservers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
  services.resolved.enable = true;

  nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      accept-flake-config = true;
      auto-optimise-store = true;
    };
  # Kernel mais recente
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ntfs" "vfat" "exfat" ];
  
  hardware.enableRedistributableFirmware = true;

  networking.networkmanager.enable = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ ];
  system.stateVersion = "25.11";

  
}
