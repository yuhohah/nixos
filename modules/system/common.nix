{ config, lib, pkgs, ... }:

{
  imports = [
    ./networking.nix
    ./audio.nix
    ./hyprland.nix
    ./greetd.nix
    ./users.nix
    ./gvfs.nix
    ./gaming.nix
    ./tracker.nix

    ../apps/core.nix
    ../apps/media.nix
    ../apps/dev.nix
    ../apps/browsers.nix
    ../apps/laptop.nix
    ../apps/waydroid.nix
    ../apps/hermes.nix
  ];
  
  options.my.system.core.enable = lib.mkEnableOption "Core System Config";

  config = lib.mkIf config.my.system.core.enable {
    boot.loader = {
      systemd-boot = {
        enable = true;
        graceful = true; # Don't fail if EFI NVRAM is full (no space for new boot entry)
      };
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
    system.stateVersion = "25.05"; # Retirado do common anterior
  };
}
