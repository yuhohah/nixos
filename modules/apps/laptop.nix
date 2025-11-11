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
    
    # Clipboard
    wl-clipboard       # Clipboard para Wayland
    cliphist           # Histórico de clipboard
    
    # Sistema
    usbutils           # lsusb
    pciutils           # lspci
    inxi               # Info do sistema
  ];
}