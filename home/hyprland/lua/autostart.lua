-- ============================================================================
-- Autostart de Sessão
-- ============================================================================

local host = {}
local ok, loaded = pcall(require, "host")
if ok and type(loaded) == "table" then
  host = loaded
end

local extra_autostart = type(host.autostart) == "table" and host.autostart or {}

hl.on("hyprland.start", function()
  hl.exec_cmd("awww-daemon")
  for _, cmd in ipairs(extra_autostart) do
    hl.exec_cmd(cmd)
  end
  hl.exec_cmd("quickshell")
end)
