{ config, pkgs, ... }:

{

   imports = [
    ./modules/system/common.nix
    
    ./modules/system/networking.nix
    ./modules/system/audio.nix
    ./modules/system/hyprland.nix
    ./modules/system/greetd.nix
    ./modules/system/users.nix
    ./modules/system/gvfs.nix

    ./modules/apps/core.nix
    ./modules/apps/media.nix
    ./modules/apps/dev.nix
    ./modules/apps/browsers.nix
  ];
  
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.resolved.enable = true;

  nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      accept-flake-config = true;
      auto-optimise-store = true;
    };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  boot.supportedFilesystems = [ "ntfs" "vfat" "exfat" ];
    
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";
}