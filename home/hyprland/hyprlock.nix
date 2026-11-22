{ ... }:

{
  programs.hyprlock = {
    enable = true;
    
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      # Background
      background = [
        {
          monitor = "";
          path = "${../../images/wallpaper/1119050.jpg}";
          blur_passes = 2;
          blur_size = 1;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      # Password field
      input-field = [
        {
          size = "300, 50";
          position = "0, -130";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(cdd6f4)";
          inner_color = "rgb(30, 30, 46)";
          outer_color = "rgb(203, 166, 247)";
          check_color = "rgb(166, 227, 161)";
          fail_color = "rgb(243, 139, 168)";
          fail_text = "<i>Senha incorreta ($ATTEMPTS)</i>";
          outline_thickness = 3;
          placeholder_text = "<span foreground='##a6adc8'>Senha...</span>";
          shadow_passes = 2;
          halign = "center";
          valign = "center";
        }
      ];

      # User picture
      image = [
        {
          monitor = "";
          path = "${../../images/profile/profile.jpg}";
          border_size = 2;
          border_color = "rgba(205, 214, 244, 0.75)";
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

      label = [
        # Relógio
        {
          monitor = "";
          text = "cmd[update:1000] date +'%H:%M:%S'";
          color = "rgb(cba6f7)";
          font_size = 70;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "0, 200";
          halign = "center";
          valign = "center";
        }

        # Data
        {
          monitor = "";
          text = "cmd[update:60000] date +'%A, %d de %B'";
          color = "rgb(a6adc8)";
          font_size = 20;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }

        # Username
        {
          monitor = "";
          text = "$USER";
          color = "rgba(203, 166, 247, 1)";
          font_size = 18;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "0, -60";
          halign = "center";
          valign = "center";
        }

        # Battery (valign = bottom usa Y positivo para subir da borda inferior)
        {
          monitor = "";
          text = "cmd[update:5000] cap=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1); [ -n \"$cap\" ] && echo \"󰁹 \${cap}%\" || echo \"󰚥 AC\"";
          color = "rgb(cba6f7)";
          font_size = 16;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "30, 30";
          halign = "left";
          valign = "bottom";
        }

        # Uptime (lê /proc/uptime diretamente; coreutils uptime não suporta -p)
        {
          monitor = "";
          text = "cmd[update:60000] awk '{s=int($1); d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60); if (d>0) printf \"󰅐 %dd %dh %dm\\n\", d, h, m; else if (h>0) printf \"󰅐 %dh %dm\\n\", h, m; else printf \"󰅐 %dm\\n\", m}' /proc/uptime";
          color = "rgb(fab387)";
          font_size = 16;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "-30, 30";
          halign = "right";
          valign = "bottom";
        }
      ];
    };
  };
}
