-- ============================================================================
-- Configuração de Monitores e Workspaces por Host
-- ============================================================================

local host = {}
local ok, loaded = pcall(require, "host")
if ok and type(loaded) == "table" then
  host = loaded
end

local monitors = type(host.monitors) == "table" and host.monitors or {}
local workspaces = type(host.workspaces) == "table" and host.workspaces or {}

for _, m in ipairs(monitors) do
  hl.monitor({
    output = m.output,
    mode = m.mode,
    position = m.position,
    scale = m.scale,
  })
end

for _, w in ipairs(workspaces) do
  hl.workspace_rule({
    workspace = w.workspace,
    monitor = w.monitor,
  })
end
