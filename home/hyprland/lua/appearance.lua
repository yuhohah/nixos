-- ============================================================================
-- Aparência, Animações e Dispositivos de Entrada
-- ============================================================================

hl.config({
  cursor = {
    no_hardware_cursors = true,
    default_monitor = "",
  },

  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 3,
    col = {
      active_border = "rgba(cba6f7ff)",     -- mauve (accent principal)
      inactive_border = "rgba(595959aa)",
    },
    layout = "dwindle",
  },

  decoration = {
    rounding = 12,
    active_opacity = 1,
    inactive_opacity = 0.85,
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

  animations = {
    enabled = true,
  }
})

-- Animações e curvas
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.animation({ leaf = "windows",    enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6,  bezier = "default" })
