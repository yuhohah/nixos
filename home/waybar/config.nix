{ config, pkgs, ... }:

{
  # Configuração da Waybar
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ./style.css;  # Opcional: se quiser CSS separado
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 24;  # Aumentei um pouco para melhor visualização
        spacing = 4;
        margin-top = 12;    # Espaço do topo
        margin-bottom = 0;
        margin-left = 12;   # Espaço das laterais
        margin-right = 12;


        interval = 1;

        modules-left = [ "hyprland/workspaces" "mpris" ];
        modules-center = [ "clock" ];
        modules-right = [ "custom/clipboard" "pulseaudio" "backlight" "network" "tray" ];

        # Módulo Hyprland - Workspaces
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
          };
        };

        # MPRIS (Media Player)
        "mpris" = {
          format = "{player_icon} {title}";
          format-paused = "{status_icon} <i>{title}</i>";
          player-icons = {
            default = "▶";
            mpv = "🎵";
          };
          status-icons = {
            paused = "⏸";
          };
          # ignored-players = ["firefox"];
          max-length = 30;
        };

        # Clipboard (Custom)
        "custom/clipboard" = {
          format = "📋";
          on-click = "cliphist list | wofi --dmenu | cliphist decode | wl-copy";
          tooltip = false;
        };

        # Relógio
        "clock" = {
          interval = 1;
          format = "{:%H:%M:%S}";
          #format-alt = "{%d/%m/%Y}";
          format-alt = "{:%A, %d de %B de %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#f5e0dc'><b>{}</b></span>";
              days = "<span color='#cdd6f4'><b>{}</b></span>";
              weeks = "<span color='#94e2d5'><b>W{}</b></span>";
              weekdays = "<span color='#f9e2af'><b>{}</b></span>";
              today = "<span color='#cba6f7'><b><u>{}</u></b></span>";
            };
          };
        };

        # Áudio
        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = " MUTE";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
          scroll-step = 5;
        };

        # Brilho
        #"backlight" = {
        #  device = "intel_backlight";
        #  format = "{icon} {percent}%";
        #  format-icons = ["" "" "" "" "" "" "" "" ""];
        #};

        # Bateria
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{time} {icon}";
          format-icons = ["" "" "" "" ""];
        };

        # Rede
        "network" = {
          format-wifi = " {signalStrength}%";
          format-ethernet = " {ifname}";
          format-disconnected = " Disconnected";
          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ifname} ";
          tooltip-format-disconnected = "Disconnected";
          max-length = 50;
          on-click = "alacritty -e nmtui";
        };

        # Tray
        "tray" = {
          spacing = 10;
        };
      };
    };
  };
}