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
    rocmPackages.clr.icd
    
    # Ferramentas de diagnóstico
    mesa-demos
    rocmPackages.rocm-smi
    gpu-viewer
    
    # Otimização para jogos
    gamemode
    mangohud
    goverlay
    gamescope

    # waydroid (managed by module)
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

  # Otimização para usuários de AMD (Mesa)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
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
  
  environment.sessionVariables = {
    PROTON_USE_NTSYNC = "1";
    # Melhora a compilação de shaders em GPUs AMD
    RADV_PERFTEST = "ngc,sam"; 
    # Reduz latência no processamento de frames
    mesa_glthread = "true";
  };
  
  # Serviços de jogos
  services.joycond.enable = true;
  services.ratbagd.enable = true;
}