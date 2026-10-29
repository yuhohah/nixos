-- ============================================================================
-- Aparência, Efeitos e Input
-- ============================================================================

local host = {}
local ok, loaded = pcall(require, "host")
if ok and type(loaded) == "table" then
  host = loaded
end
local hostname = host.hostname or "nixos-btw"

local kb_layout = "us"
local kb_variant = "intl"

if hostname == "arrow" then
  kb_layout = "br,es"
  kb_variant = "abnt2,"
end

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 2,
    col = {
      active_border = {
        colors = { "rgba(cba6f7ee)", "rgba(b4befeee)" },
        angle = 45,
      },
      inactive_border = "rgba(313244aa)",
    },
    layout = "dwindle",
  },

  decoration = {
    rounding = 8,
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
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
    kb_layout = kb_layout,
    kb_variant = kb_variant,
    kb_options = "caps:escape, grp:alt_shift_toggle",
    follow_mouse = 1,
    touchpad = {
      natural_scroll = true,
    },
    sensitivity = 0,
    accel_profile = "flat",
    force_no_accel = true,
  },

  cursor = {
    no_hardware_cursors = true,
    enable_hyprcursor = true,
  },
})
