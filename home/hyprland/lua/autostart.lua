-- ============================================================================
-- Autostart de Sessão
-- ============================================================================

hl.on("hyprland.start", function()
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("hyprlock")
  hl.exec_cmd("corectrl --minimize-systray")
  hl.exec_cmd("quickshell")
end)
