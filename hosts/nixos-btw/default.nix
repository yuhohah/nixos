{ config, pkgs, ... }:

{
  networking.hostName = "nixos-btw";
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
  ];

  generationTracker.configDir = "/home/luan/Configuration/nixos";

  my.system.core.enable = true;
  my.system.networking.enable = true;
  my.system.audio.enable = true;
  my.system.hyprland.enable = true;
  my.system.greetd.enable = true;
  my.system.users.enable = true;
  my.system.gvfs.enable = true;
  my.system.gaming.enable = true;

  my.apps.core.enable = true;
  my.apps.media.enable = true;
  my.apps.dev.enable = true;
  my.apps.browsers.enable = true;
  my.apps.waydroid.enable = true;
  my.apps.hermes.enable = true;

  # Kernel mais recente
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel modules para jogos e Waydroid
  boot.kernelModules = [ "ntsync" "binder_linux" ];

  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642; 
  };

  fileSystems."/mnt/disk" = {
    device = "/dev/disk/by-uuid/CA28A08128A06E5F";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=100" "dmask=000" "fmask=000" "allow_other" ];
  };
}
