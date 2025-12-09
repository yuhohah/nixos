{ config, pkgs, ... }:

{
  networking.hostName = "arrow";
  imports = [
    ./hardware-arrow.nix
    
    ./modules/system/networking.nix
    ./modules/system/audio.nix
    ./modules/system/hyprland.nix
    ./modules/system/greetd.nix
    ./modules/system/gaming.nix
    ./modules/system/users.nix
    #./modules/system/logind.nix # Notebook specific

    ./modules/apps/core.nix
    ./modules/apps/media.nix
    ./modules/apps/dev.nix
    ./modules/apps/browsers.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  systemd.user.services.numlock = {
    enable = true;
    description = "Activate NumLock";
    after = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.numlockx}/bin/numlockx on";
      RemainAfterExit = true;
    };
    wantedBy = [ "graphical-session.target" ];
  };



  nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      accept-flake-config = true;
      auto-optimise-store = true;
    };
  # Kernel mais recente
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";

  
}
