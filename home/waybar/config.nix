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

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "backlight" "network" "tray" ];

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

        # Módulo Hyprland - Janela Ativa
        #"hyprland/window" = {
         # format = "{}";
        #  max-length = 50;
       #   separate-outputs = true;
      #  };

        # Relógio
        "clock" = {
          format = "{:%H:%M:%S}";
          #format-alt = "{%d/%m/%Y}";
          format-alt = "{:%A, %d de %B de %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
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
          on-click = "nm-connection-editor";
        };

        # Tray
        "tray" = {
          spacing = 10;
        };
      };
    };
  };
}