{ config, lib, pkgs, unstable, ... }:
{
  options.my.apps.laptop.enable = lib.mkEnableOption "Laptop Apps Config";

  config = lib.mkIf config.my.apps.laptop.enable {
    environment.systemPackages = with pkgs; [
      # Gerenciamento de energia
      brightnessctl       # Controle de brilho
      pamixer            # Controle de volume via CLI
      playerctl          # Controle de media players
      acpi               # Informações de bateria
      powertop           # Monitor de consumo de energia
      
      # Rede
      networkmanagerapplet  # Applet de rede
      
      # Bluetooth
      blueman            # Gerenciador Bluetooth GUI
      bluez              # Stack Bluetooth
      bluez-tools        # Ferramentas Bluetooth CLI
      
      # Display
      wdisplays          # Configurar monitores externos
      wlr-randr          # Gerenciar displays via CLI
      
      # Ferramentas úteis
      wlogout            # Menu de logout/suspend/shutdown
      lm_sensors         # Sensores de temperatura
      
      # Sistema
      usbutils           # lsusb
      pciutils           # lspci
      inxi               # Info do sistema
      tlp
    ];

    services.power-profiles-daemon.enable = false;

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
  };
}