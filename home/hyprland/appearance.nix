{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {

    # ========================================
    # CURSOR
    # ========================================
    cursor = {
      no_hardware_cursors = true;  # Importante para evitar bugs
      default_monitor = "";
    };

    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 3;
      "col.active_border" = "rgba(a6e3a1ff)";
      "col.inactive_border" = "rgba(595959aa)";
      layout = "dwindle";
    };

    decoration = {
      rounding = 8;
      blur = {
        enabled = true;
        size = 8;
        passes = 3;
        new_optimizations = true;
      };
    };

    animations = {
      enabled = true;
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
      ];
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };


    misc = {
      force_default_wallpaper = 0;
      disable_hyprland_logo = true;
      animate_manual_resizes = true;
      animate_mouse_windowdragging = true;
    };

    input = {
      kb_layout = "us";
      kb_variant = "intl";
      kb_options = "caps:escape";
      follow_mouse = 1;
      touchpad = {
        natural_scroll = true;
      };
      sensitivity = 0;
      accel_profile = "flat"; 
      force_no_accel = true;
    };
  };
}