-- ============================================================================
-- Configuração de Monitores e Workspaces por Host
-- ============================================================================

local host = {}
local ok, loaded = pcall(require, "host")
if ok and type(loaded) == "table" then
  host = loaded
end

local hostname = host.hostname or "nixos-btw"

if hostname == "arrow" then
  -- Perfil Laptop (arrow)
  hl.monitor({ output = "eDP-1", mode = "1920x1080", position = "0x0", scale = "1" })
  hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@144", position = "1920x0", scale = "1" })

  hl.workspace_rule({ workspace = "1", monitor = "eDP-1" })
else
  -- Perfil Desktop (nixos-btw)
  hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@144", position = "0x0", scale = "1" })
  hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@74.973", position = "1920x0", scale = "1" })

  hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1" })
  hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-2" })
  hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1" })
  hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-2" })
end
