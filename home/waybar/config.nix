{ config, pkgs, ... }:

{
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

        modules-left = [ "group/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "custom/clipboard" "pulseaudio" "backlight" "cpu" "memory" "network" "tray" ];

        # Workspaces - Grupo de botões com despacho Lua
        "group/workspaces" = {
          orientation = "horizontal";
          modules = [
            "custom/ws1"
            "custom/ws2"
            "custom/ws3"
            "custom/ws4"
            "custom/ws5"
            "custom/ws6"
            "custom/ws7"
            "custom/ws8"
            "custom/ws9"
            "custom/ws10"
          ];
        };
        # Botões individuais com sintaxe Lua
        "custom/ws1" = {
          format = "1";
          on-click = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"1\" })'";
          tooltip = false;
        };
        "custom/ws2" = {
          format = "2";
          on-click = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"2\" })'";
          tooltip = false;
        };
        "custom/ws3" = {
          format = "3";
          on-click = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"3\" })'";
          tooltip = false;
        };
        "custom/ws4" = {
          format = "4";
          on-click = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"4\" })'";
          tooltip = false;
        };
        "custom/ws5" = {
          format = "5";
          on-click = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"5\" })'";
          tooltip = false;
        };
        "custom/ws6" = {
          format = "6";
          on-click = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"6\" })'";
          tooltip = false;
        };
        "custom/ws7" = {
          format = "7";
          on-click = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"7\" })'";
          tooltip = false;
        };
        "custom/ws8" = {
          format = "8";
          on-click = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"8\" })'";
          tooltip = false;
        };
        "custom/ws9" = {
          format = "9";
          on-click = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"9\" })'";
          tooltip = false;
        };
        "custom/ws10" = {
          format = "10";
          on-click = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"10\" })'";
          tooltip = false;
        };

        # Clock
        "clock" = {
          interval = 1;
          format = "{:%H:%M:%S}";
          format-alt = "{:%A, %d de %B de %Y}";
          tooltip-format = "<tt><span size='13pt' font='JetBrainsMono Nerd Font'>{calendar}</span></tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#cba6f7'><b>{}</b></span>";
              days = "<span color='#cdd6f4'>{}</span>";
              weeks = "<span color='#94e2d5'><b>W{}</b></span>";
              weekdays = "<span color='#f9e2af'><b>{}</b></span>";
              today = "<span color='#11111b' background='#cba6f7'><b>{}</b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        # Audio
        "pulseaudio" = {
          format = "{icon}  {volume}%";
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

        # Network
        "network" = {
          format-wifi = "  {signalStrength}%";
          format-ethernet = " {ifname}";
          format-disconnected = " Disconnected";
          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ifname} ";
          tooltip-format-disconnected = "Disconnected";
          max-length = 50;
          on-click = "alacritty -e nmtui";
        };

        "memory" = {
          "format"= "mem: {used:0.1f}G";
          "tooltip"= true;
          "tooltip-format" = "RAM: Used {used:0.1f}G / Free {total:0.1f}G";
          "interval"= 4;
        };

        "cpu" = {
          interval = 2;
          format = "cpu: {usage}%";
          tooltip = true;
          tooltip-format = "CPU Usage: {usage}%\nCores: {cores}";
          on-click = "alacritty -e btop";
        };

        # Tray
        "tray" = {
          spacing = 10;
        };
      };
    };
  };
}
