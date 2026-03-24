{ config, pkgs, ... }:

{
  # ========================================
  # HYPRIDLE - GERENCIADOR DE INATIVIDADE
  # ========================================
  
  services.hypridle = {
    enable = true;
    
    settings = {
      general = {
        # Tempo antes de travar (em segundos)
        lock_cmd = "pidof hyprlock || hyprlock";  # Evita múltiplas instâncias
        before_sleep_cmd = "loginctl lock-session";  # Trava antes de suspender
        after_sleep_cmd = "hyprctl dispatch dpms on";  # Liga tela após acordar
      };

      # Listeners - Ações baseadas em tempo de inatividade
      listener = [
        # Após 5 minutos: Diminui brilho para 10%
        # Após 5 minutos: Screensaver
        {
          ignore_inhibit = true;
          timeout = 150; # 2,5 minutos
          on-timeout = "brightnessctl set 10% && ~/.local/bin/run-screensaver";
          on-resume = "brightnessctl set 60% && pkill -f 'alacritty.*screensaver'";
        }
        
        # Após 10 minutos: Desliga tela
        {
          timeout = 480;  # 8 minutos
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        
        # Após 15 minutos: Trava a sessão
        {
          timeout = 720;  # 12 minutos
          on-timeout = "loginctl lock-session";
        }
        
        # Após 30 minutos: Suspende o sistema
        {
          timeout = 900;  # 15 minutos
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };



}