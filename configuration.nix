{ config, pkgs, ... }:

{
  networking.hostName = "nixos-btw";
  imports = [
    ./hardware-configuration.nix
    
    ./modules/system/networking.nix
    ./modules/system/audio.nix
    ./modules/system/hyprland.nix
    ./modules/system/greetd.nix
    ./modules/system/gaming.nix
    ./modules/system/users.nix
    ./modules/system/gvfs.nix

    ./modules/apps/core.nix
    ./modules/apps/media.nix
    ./modules/apps/dev.nix
    ./modules/apps/browsers.nix
    ./modules/apps/waydroid.nix
    ./modules/apps/hermes.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

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

  # Kernel mais recente
  # boot.kernelPackages = pkgs.linuxPackages_zen; 
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel modules para jogos e Waydroid
  boot.kernelModules = [ "ntsync" "binder_linux" ];

  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642; # Necessário para muitos motores modernos
    # "kernel.sched_rt_runtime_us" = -1; # Evita que o scheduler interrompa processos em tempo real
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "qtwebengine-5.15.19" ];
  system.stateVersion = "25.05";

  fileSystems."/mnt/disk" = {
    device = "/dev/disk/by-uuid/CA28A08128A06E5F";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=100" "dmask=000" "fmask=000" "allow_other" ];
  };
}

