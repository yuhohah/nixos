{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;
    
    # Aparência Geral
    font = "JetBrainsMono Nerd Font Mono 12";
    padding = "15";
    margin = "10";
    anchor = "top-right";
    width = 350;
    height = 150;
    
    # Bordas (Arredondadas igual à Waybar)
    borderSize = 2;
    borderRadius = 12;
    
    # Cores (Baseadas no seu colors.nix e style.css)
    backgroundColor = "#1e1e1ef2";  # Cinza escuro com 95% de opacidade
    borderColor = "#a6e3a1";        # Verde (Accent do seu sistema)
    textColor = "#cdd6f4";          # Texto principal
    progressColor = "over #313244"; # Barra de progresso sutil
    
    # Ícones
    icons = true;
    iconPath = "${pkgs.adwaita-icon-theme}/share/icons/Adwaita";
    maxIconSize = 48;
    
    # Comportamento
    defaultTimeout = 5000; # 5 segundos
    ignoreTimeout = true;  # Não some se você estiver com o mouse em cima
    layer = "overlay";
    
    # Configurações Extras por Urgência
    extraConfig = ''
      [urgency=high]
      border-color=#f38ba8
      default-timeout=0
      
      [urgency=low]
      border-color=#1e1e2e
      default-timeout=2000
      
      [mode=do-not-disturb]
      invisible=1
    '';
  };
}