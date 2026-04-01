{ config, pkgs, ... }:

{
  # Waybar Configuration for Notebook
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ./style.css;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 24;
        spacing = 4;
        margin-top = 12;
        margin-bottom = 0;
        margin-left = 12;
        margin-right = 12;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "custom/clipboard" "pulseaudio" "backlight" "battery" "network" "tray" ];

        # Workspaces
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

        # Clock
        "clock" = {
          format = "{:%H:%M:%S}";
          format-alt = "{:%A, %d de %B de %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#ffffffff'><b>{}</b></span>";
              days = "<span color='#f33a97ff'><b>{}</b></span>";
              weeks = "<span color='#3675fcff'><b>W{}</b></span>";
              weekdays = "<span color='#f7f200ff'><b>{}</b></span>";
              today = "<span color='#a6e3a1'><b><u>{}</u></b></span>";
            };
          };
        };

        # Audio
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

        # Backlight
        "backlight" = {
          # device = "intel_backlight"; # Auto-detect by default
          format = "{icon} {percent}%";
          format-icons = ["" "" "" "" "" "" "" "" ""];
          on-scroll-up = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
        };

        # Battery
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

        # Network
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
