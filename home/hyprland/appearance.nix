{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    extraConfig = ''
      -- ========================================
      -- CONFIGURAÇÕES GERAIS (hl.config)
      -- ========================================
      hl.config({
        cursor = {
          no_hardware_cursors = true,  -- Importante para evitar bugs
          default_monitor = "",
        },
        
        general = {
          gaps_in = 5,
          gaps_out = 10,
          border_size = 3,
          -- A propriedade de cores vira uma subtabela "col"
          col = {
            active_border = "rgba(cba6f7ff)",     -- mauve (accent principal)
            inactive_border = "rgba(595959aa)",
          },
          layout = "dwindle",
        },

        decoration = {
          rounding = 0,
          active_opacity = 0.8,
          inactive_opacity = 0.65,
          fullscreen_opacity = 1.0,

          blur = {
            enabled = true,
            size = 6,
            passes = 3,
            new_optimizations = true,
            vibrancy = 0.1696,
            noise = 0.02,
            xray = false,
          },

          shadow = {
            enabled = true,
            range = 12,
            render_power = 3,
            color = "rgba(1a1a2eee)",
          },
        },

        dwindle = {
          preserve_split = true,
        },

        misc = {
          force_default_wallpaper = 0,
          disable_hyprland_logo = true,
          animate_manual_resizes = true,
          animate_mouse_windowdragging = true,
          vrr = 1,
        },

        input = {
          kb_layout = "us,br,es",
          kb_variant = "intl,abnt2",
          kb_options = "caps:escape, grp:alt_shift_toggle",
          follow_mouse = 1,
          touchpad = {
            natural_scroll = true,
          },
          sensitivity = 0,
          accel_profile = "flat",
          force_no_accel = true,
        },
        
        -- Ativa as animações de forma global
        animations = {
          enabled = true,
        }
      })

      -- ========================================
      -- ANIMAÇÕES (API hl.curve e hl.animation)
      -- ========================================
      -- Converte os pontos (0.05, 0.9, 0.1, 1.05) para o formato nativo da API
      hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

      -- Aplica as regras de animação
      hl.animation({ leaf = "windows",    enabled = true, speed = 7,  bezier = "myBezier" })
      hl.animation({ leaf = "windowsOut", enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
      hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "default" })
      hl.animation({ leaf = "fade",       enabled = true, speed = 7,  bezier = "default" })
      hl.animation({ leaf = "workspaces", enabled = true, speed = 6,  bezier = "default" })
    '';
  };
}