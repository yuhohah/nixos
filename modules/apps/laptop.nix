{ pkgs, unstable, ... }:
{
  environment.systemPackages = with pkgs; [
    # ========================================
    # PACOTES ESPECÍFICOS PARA NOTEBOOK
    # ========================================
    
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
    #acpilight          # Alternativa ao brightnessctl
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
      # Better handling for Intel 12th Gen P/E cores
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      
      # Scaling driver for modern Intel
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      # Optional: Disable turbo on battery to keep the laptop cool/quiet
      CPU_BOOST_ON_BAT = 0;
    };
  };
}