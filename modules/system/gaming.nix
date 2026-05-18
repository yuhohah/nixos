{ config, lib, pkgs, ... }:

{
  options.my.system.gaming.enable = lib.mkEnableOption "Gaming Config";

  config = lib.mkIf config.my.system.gaming.enable {
    environment.systemPackages = with pkgs; [
      vulkan-tools
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
      mesa
      rocmPackages.clr.icd
      mesa-demos
      rocmPackages.rocm-smi
      gpu-viewer
      gamemode
      mangohud
      goverlay
      gamescope
    ];

    programs.gamemode = {
      enable = true;
      settings = {
        general = { renice = 10; };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
        };
      };
    };

    programs.corectrl = {
      enable = true;
      #gpuOverclock.enable = true;
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
    };

    hardware.steam-hardware.enable = true;
    
    environment.sessionVariables = {
      PROTON_USE_NTSYNC = "1";
      RADV_PERFTEST = "ngc,sam"; 
      mesa_glthread = "true";
    };
    
    services.joycond.enable = true;
    services.ratbagd.enable = true;
  };
}