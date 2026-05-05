{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;
    settings = {
      # Aparência — Frosted Glass
      font = "JetBrainsMono Nerd Font Mono 11";
      padding = "15,20";
      margin = "12";
      anchor = "top-right";
      width = 380;
      height = 160;
      outer-margin = "10";

      # Bordas — suaves e translúcidas
      border-size = 2;
      border-radius = 16;

      # Cores — vidro fosco com borda mauve sutil
      background-color = "#1e1e2ea8";        # ~66% opacidade — blur do Hyprland completa
      border-color = "#cba6f759";             # mauve translúcido
      text-color = "#cdd6f4";                 # texto catppuccin
      progress-color = "over #cba6f733";      # progresso mauve sutil

      # Ícones
      icons = true;
      icon-path = "${pkgs.adwaita-icon-theme}/share/icons/Adwaita";
      max-icon-size = 48;

      # Comportamento
      default-timeout = 4000;
      ignore-timeout = true;
      layer = "overlay";

      # Urgência alta — borda vermelha, não some automaticamente
      "urgency=high" = {
        border-color = "#f38ba8cc";
        default-timeout = 0;
      };

      # Urgência baixa — mais discreta
      "urgency=low" = {
        border-color = "#45475a80";
        default-timeout = 2500;
      };

      # Modo Não Perturbe
      "mode=do-not-disturb" = {
        invisible = true;
      };
    };
  };
}