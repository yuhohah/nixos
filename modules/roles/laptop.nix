{ config, lib, pkgs, ... }:

{
  options.my.roles.laptop.enable = lib.mkEnableOption "Laptop Role (power management, mobility and mobile desktop profile)";

  config = lib.mkIf config.my.roles.laptop.enable {
    # Ferramentas e utilitários para mobilidade / laptop
    environment.systemPackages = with pkgs; [
      brightnessctl       # Controle de brilho de tela
      pamixer             # Controle de volume via CLI
      playerctl           # Controle de media players
      acpi                # Informações de bateria
      powertop            # Monitor de consumo de energia
      networkmanagerapplet # Applet de rede
      wdisplays           # Configuração de displays externos
      wlr-randr           # Gerenciamento de monitores via CLI
      wlogout             # Menu de logout / suspend / shutdown
      lm_sensors          # Sensores térmicos
      usbutils            # lsusb
      pciutils            # lspci
      inxi                # Informações do sistema
      tlp                 # Gerenciamento avançado de energia
    ];

    # Serviços de energia
    services.power-profiles-daemon.enable = false;
    services.upower.enable = true;

    services.tlp = {
      enable = true;
      settings = {
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_BOOST_ON_BAT = 0;
      };
    };

    # Daemons de hardware e automação
    services.acpid.enable = true;
    services.udisks2.enable = true;
    services.blueman.enable = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
          JustWorksRepairing = "always";
          Privacy = "device";
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };

    # Injeção de perfil no Home Manager
    home-manager.users.luan.imports = [
      ../../home/waybar/notebook.nix
      ../../home/scripts/battery-alert.nix
    ];
  };
}
