-- ============================================================================
-- Regras de Janela e Camada (Rules)
-- ============================================================================

hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
})

-- Correção de foco e dimensionamento para o Steam
hl.window_rule({
  name = "steam-fix",
  match = { class = "^(steam)$", title = "^()$" },
  stay_focused = true,
  min_size = "1 1",
})

-- Screensaver em tela cheia em todos os monitores (sem inibir idle)
hl.window_rule({
  name = "screensaver-fullscreen",
  match = { class = "^(screensaver)$" },
  fullscreen = true,
  no_anim = true,
  idle_inhibit = "none",
})

-- Efeito blur e opacidade para o Quickshell Desktop Shell
hl.layer_rule({
  name = "quickshell-blur",
  match = { namespace = "quickshell.*" },
  blur = true,
  ignore_alpha = 0,
})