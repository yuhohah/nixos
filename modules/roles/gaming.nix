{ config, lib, pkgs, ... }:

{
  options.my.roles.gaming.enable = lib.mkEnableOption "Gaming Role (Steam, GameMode, graphics, kernel tuning and desktop profile)";

  config = lib.mkIf config.my.roles.gaming.enable {
    # Pacotes do ecossistema de jogos e diagnósticos de GPU
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

    # Otimização GameMode
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

    # Controle de GPU
    programs.corectrl = {
      enable = true;
    };

    # Drivers e aceleração gráfica 32-bit
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Steam e integração de periféricos
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
    };

    hardware.steam-hardware.enable = true;

    # Variáveis de ambiente para desempenho gráfico e Proton
    environment.sessionVariables = {
      PROTON_USE_NTSYNC = "1";
      RADV_PERFTEST = "ngc,sam";
      mesa_glthread = "true";
    };

    services.joycond.enable = true;
    services.ratbagd.enable = true;

    # Otimizações de Kernel e módulos para jogos e emuladores
    boot.kernelModules = [ "ntsync" "binder_linux" ];
    boot.kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };

    # Injeção de perfil no Home Manager
    home-manager.users.luan.imports = [
      ../../home/waybar/config.nix
      ../../home/vesktop/config.nix
    ];
  };
}
