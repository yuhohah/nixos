{ config, pkgs, ... }:

{
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
          path = "~/Pictures/wallpaper/1119050.jpg";  # Seu wallpaper
          blur_passes = 2;
          blur_size = 1;
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
          position = "0, -130";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(cdd6f4)";
          inner_color = "rgb(30, 30, 46)";
          outer_color = "rgb(166, 227, 161)";  # Verde (sua cor)
          outline_thickness = 3;
          placeholder_text = "<span foreground='##a6adc8'>Senha...</span>";
          shadow_passes = 2;
          halign = "center";
          valign = "center";
        }
      ];

      # ========================================
      # IMAGE (Foto de perfil)
      # ========================================
      image = [
        {
          path = "~/Pictures/profile/perfil.png";
          border_size = 2;
          border_color = "rgba(255, 255, 255, .75)";
          size = 95;
          rounding = -1;
          rotate = 0;
          reload_time = -1;
          reload_cmd = "";
          position = "0, 10";
          halign = "center";
          valign = "center";
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
          font_size = 70;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
        
        # Data
        {
          monitor = "";
          text = "cmd[update:3600000] echo \"<span foreground='##a6adc8'>$(date +'%A, %d de %B')</span>\"";
          color = "rgba(29, 37, 63, 1)";
          font_size = 20;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
        
        # Nome do usuário
        {
          monitor = "";
          text = "$USER";
          color = "rgba(166, 227, 161)";
          font_size = 18;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "0, -60";
          halign = "center";
          valign = "center";
        }
        
        # Status da bateria (se for notebook)
        {
          monitor = "";
          text = "cmd[update:5000] echo \"<span foreground='##a6e3a1'>󰁹 $(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo 'AC')%</span>\"";
          color = "rgba(20, 26, 46, 1)";
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
          color = "rgba(16, 25, 53, 1)";
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
