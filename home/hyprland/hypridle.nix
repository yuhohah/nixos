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
        #{
        #  timeout = 300;  # 5 minutos
        #  on-timeout = "brightnessctl -s set 10%";
        #  on-resume = "brightnessctl -r";
        #}
        
        # Após 10 minutos: Desliga tela
        {
          timeout = 600;  # 10 minutos
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        
        # Após 15 minutos: Trava a sessão
        {
          timeout = 900;  # 15 minutos
          on-timeout = "loginctl lock-session";
        }
        
        # Após 30 minutos: Suspende o sistema
        {
          timeout = 1800;  # 30 minutos
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  # ========================================
  # HYPRLOCK - TELA DE BLOQUEIO
  # ========================================
  
  programs.hyprlock = {
    enable = true;
    
    settings = {
      general = {
        disable_loading_bar = false;
        grace = 100000;  # Segundos de graça antes de pedir senha
        hide_cursor = true;
        no_fade_in = false;
      };

      # ========================================
      # BACKGROUND (Wallpaper desfocado)
      # ========================================
      background = [
        {
          path = "~/Pictures/wallpaper/226711.jpg";  # Seu wallpaper
          blur_passes = 3;
          blur_size = 7;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      # ========================================
      # INPUT FIELD (Campo de senha)
      # ========================================
      input-field = [
        {
          size = "300, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(cdd6f4)";
          inner_color = "rgb(30, 30, 46)";
          outer_color = "rgb(166, 227, 161)";  # Verde (sua cor)
          outline_thickness = 3;
          placeholder_text = "<span foreground='##a6adc8'>Senha...</span>";
          shadow_passes = 2;
        }
      ];

      # ========================================
      # LABELS (Textos na tela)
      # ========================================
      label = [
        # Relógio
        {
          monitor = "";
          text = "cmd[update:1000] echo \"<span foreground='##a6e3a1'>$(date +'%H:%M:%S')</span>\"";
          color = "rgb(205, 214, 244)";
          font_size = 90;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
        
        # Data
        {
          monitor = "";
          text = "cmd[update:3600000] echo \"<span foreground='##a6adc8'>$(date +'%A, %d de %B')</span>\"";
          color = "rgb(205, 214, 244)";
          font_size = 20;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
        
        # Nome do usuário
        {
          monitor = "";
          text = "  $USER";
          color = "rgb(205, 214, 244)";
          font_size = 18;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "0, -20";
          halign = "center";
          valign = "center";
        }
        
        # Status da bateria (se for notebook)
        {
          monitor = "";
          text = "cmd[update:5000] echo \"<span foreground='##a6e3a1'>󰁹 $(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo 'AC')%</span>\"";
          color = "rgb(205, 214, 244)";
          font_size = 16;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "30, -30";
          halign = "left";
          valign = "bottom";
        }
        
        # Uptime
        {
          monitor = "";
          text = "cmd[update:60000] echo \"<span foreground='##fab387'>󱫐 $(uptime -p | sed 's/up //')</span>\"";
          color = "rgb(205, 214, 244)";
          font_size = 16;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "-30, -30";
          halign = "right";
          valign = "bottom";
        }
      ];
    };
  };

}