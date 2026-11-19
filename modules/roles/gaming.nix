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
      mesa-demos
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
          gpu_device = 1;
          amd_performance_level = "high";
        };
      };
    };

    # Controle e OverDrive de GPU AMD (usa ppfeaturemask seguro padrão 0xfffd7fff)
    programs.corectrl.enable = true;
    hardware.amdgpu.overdrive.enable = true;

    # Permissões para GameMode (renice/GPU) e CoreCtrl sem pedir senha
    users.users.luan.extraGroups = [ "gamemode" "corectrl" ];

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
      mesa_glthread = "true";
    };

    services.joycond.enable = true;
    services.ratbagd.enable = true;

    # Otimizações de Kernel e módulos para jogos e emuladores
    boot.kernelModules = [ "ntsync" "binder_linux" ];
    boot.kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };
  };
}
