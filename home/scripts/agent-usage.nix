{ lib, pkgs, ... }:

let
  quickshellAgentUsageT3code = pkgs.writeScriptBin "quickshell-agent-usage-t3code" (
    "#!${pkgs.python3}/bin/python3\n" + builtins.readFile ./agent-usage-t3code.py
  );

  quickshellAgentUsageUpdate = pkgs.writeShellScriptBin "quickshell-agent-usage-update" ''
    USAGE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/agents/usage"
    mkdir -p "$USAGE_DIR"
    rm -f "$USAGE_DIR/gemini.json"

    exec ${quickshellAgentUsageT3code}/bin/quickshell-agent-usage-t3code "$@"
  '';

  omarchyAgentUsageUpdate = pkgs.writeShellScriptBin "omarchy-agent-usage-update" ''
    exec quickshell-agent-usage-update "$@"
  '';

  quickshellAgent = pkgs.writeShellScriptBin "quickshell-agent" ''
    if command -v xdg-open >/dev/null 2>&1; then
      xdg-open "http://127.0.0.1:3773" >/dev/null 2>&1 &
    fi
  '';

  omarchyAgent = pkgs.writeShellScriptBin "omarchy-agent" ''
    exec quickshell-agent "$@"
  '';

  agentPackages = [
    quickshellAgentUsageT3code
    quickshellAgentUsageUpdate
    omarchyAgentUsageUpdate
    quickshellAgent
    omarchyAgent
  ];
in
{
  options.agentUsage = {
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = agentPackages;
      description = "Pacotes do subsistema de métricas do agente de IA.";
    };
  };

  config = {
    systemd.user.services.agent-usage-tracker = {
      Unit = {
        Description = "AI Agent Usage Metrics Tracker";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${quickshellAgentUsageUpdate}/bin/quickshell-agent-usage-update";
        Environment = "PATH=${lib.makeBinPath [ pkgs.coreutils ]}";
      };
    };

    systemd.user.timers.agent-usage-tracker = {
      Unit = {
        Description = "Periodic AI Agent Usage Tracker Update";
      };
      Timer = {
        OnBootSec = "1m";
        OnUnitActiveSec = "2m";
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
