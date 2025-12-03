{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Vulkan
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    vulkan-extension-layer
    
    # Mesa
    mesa
    
    # Drivers AMD
    amdvlk
    rocmPackages.clr.icd
    
    # Ferramentas de diagnóstico
    glxinfo
    rocmPackages.rocm-smi
    gpu-viewer
    
    # Otimização para jogos
    gamemode
    mangohud
    goverlay
    gamescope

    waydroid
  ];




  # Gamemode
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # Controles
  hardware.steam-hardware.enable = true;
  
  # Serviços de jogos
  services.joycond.enable = true;
  services.ratbagd.enable = true;
}