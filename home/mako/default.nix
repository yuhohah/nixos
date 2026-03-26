{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;
    settings = {
      # Aparência Geral
      font = "JetBrainsMono Nerd Font Mono 12";
      padding = "15";
      margin = "10";
      anchor = "top-right";
      width = 350;
      height = 150;
      
      # Bordas (Arredondadas igual à Waybar)
      border-size = 2;
      border-radius = 12;
      
      # Cores (Baseadas no seu colors.nix e style.css)
      background-color = "#1e1e1ef2";  # Cinza escuro com 95% de opacidade
      border-color = "#a6e3a1";        # Verde (Accent do seu sistema)
      text-color = "#cdd6f4";          # Texto principal
      progress-color = "over #313244"; # Barra de progresso sutil
      
      # Ícones
      icons = true;
      icon-path = "${pkgs.adwaita-icon-theme}/share/icons/Adwaita";
      max-icon-size = 48;
      
      # Comportamento
      default-timeout = 3000; # 5 segundos
      ignore-timeout = true;  # Não some se você estiver com o mouse em cima
      layer = "overlay";
      
      # Configurações Extras por Urgência
      #extraConfig = ''
      #  [urgency=high]
      #  border-color=#f38ba8
      #  default-timeout=0
      #  
      #  [urgency=low]
      #  border-color=#1e1e2e
      #  default-timeout=2000
      #  
      #  [mode=do-not-disturb]
      #  invisible=1
      #'';
    };
  };
}