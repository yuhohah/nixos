{ config, pkgs, ... }:

{
  networking.hostName = "nixos-btw";
  imports = [
    ./hosts/nixos-btw/hardware-configuration.nix
    
    ./modules/system/networking.nix
    ./modules/system/gaming.nix

    ./modules/apps/waydroid.nix
    ./modules/apps/hermes.nix
  ];

  # Kernel mais recente
  # boot.kernelPackages = pkgs.linuxPackages_zen; 
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel modules para jogos e Waydroid
  boot.kernelModules = [ "ntsync" "binder_linux" ];

  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642; # Necessário para muitos motores modernos
    # "kernel.sched_rt_runtime_us" = -1; # Evita que o scheduler interrompa processos em tempo real
  };

  fileSystems."/mnt/disk" = {
    device = "/dev/disk/by-uuid/CA28A08128A06E5F";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=100" "dmask=000" "fmask=000" "allow_other" ];
  };
}

