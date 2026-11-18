-- ============================================================================
-- Autostart de Sessão
-- ============================================================================

local host = {}
local ok, loaded = pcall(require, "host")
if ok and type(loaded) == "table" then
  host = loaded
end
local hostname = host.hostname or "nixos-btw"

hl.on("hyprland.start", function()
  hl.exec_cmd("awww-daemon")
  if hostname == "nixos-btw" then
    hl.exec_cmd("corectrl --minimize-systray")
  end
  hl.exec_cmd("quickshell")
end)
