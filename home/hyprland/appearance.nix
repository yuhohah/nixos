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
      # "col.active_border" = "rgba(a6e3a1ff)";  # verde (backup)
      "col.active_border" = "rgba(cba6f7ff)";     # mauve (accent principal)
      "col.inactive_border" = "rgba(595959aa)";
      layout = "dwindle";
    };

    decoration = {
      rounding = 12;

      # Opacidade sutil para revelar o blur através das janelas
      active_opacity = 0.95;
      inactive_opacity = 0.85;
      fullscreen_opacity = 1.0;

      blur = {
        enabled = true;
        size = 6;
        passes = 3;
        new_optimizations = true;
        vibrancy = 0.1696;        # efeito de vidro fosco
        noise = 0.02;             # granulado sutil para sofisticação
        xray = false;
      };

      shadow = {
        enabled = true;
        range = 12;
        render_power = 3;
        color = "rgba(1a1a2eee)";
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
      preserve_split = true;
    };


    misc = {
      force_default_wallpaper = 0;
      disable_hyprland_logo = true;
      animate_manual_resizes = true;
      animate_mouse_windowdragging = true;
      vrr = 1;
    };

    input = {
      kb_layout = "us,br,es";
      kb_variant = "intl,abnt2";
      kb_options = "caps:escape, grp:alt_shift_toggle";
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