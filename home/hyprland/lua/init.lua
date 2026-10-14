-- ============================================================================
-- Hyprland Native Lua Entrypoint
-- ============================================================================

-- Configura caminhos para permitir require() relativo a ~/.config/hypr e ./lua
local home = os.getenv("HOME") or ""
package.path = home .. "/.config/hypr/lua/?.lua;"
            .. home .. "/.config/hypr/?.lua;"
            .. package.path

-- Carrega submódulos
require("appearance")
require("rules")
require("autostart")
require("keybinds")
require("monitors")
