{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Primeiro, descubra os nomes dos seus monitores
    monitor = [
      # Formato: "Nome,Resolução,Posição,Scale"
      
      # Exemplo: Monitor primário
      "HDMI-A-1,1920x1080@144,0x0,1"
      
      # Exemplo: Monitor externo à direita
      "HDMI-A-2,1920x1080@74.973,1920x0,1"
      
      # Exemplo: Monitor externo acima
      # "DP-1,1920x1080,0x-1080,1"
      
      # Exemplo: Com scale para HiDPI
      # "eDP-1,2880x1800,0x0,2"
    ];
    
    # Workspaces por monitor (opcional)
    workspace = [
      "1, monitor:HDMI-A-1"  # Workspace 1 no monitor primário
      "2, monitor:HDMI-A-2"  # Workspace 2 no monitor externo
      "3, monitor:HDMI-A-1"
      "4, monitor:HDMI-A-2"
    ];
  };
}