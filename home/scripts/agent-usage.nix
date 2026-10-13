{ lib, pkgs, ... }:

let
  quickshellAgentUsageGemini = pkgs.writeScriptBin "quickshell-agent-usage-gemini" ''#!${pkgs.python3}/bin/python3
import os, sys, glob, json, datetime

brain_dir = os.path.expanduser("~/.gemini/antigravity-ide/brain")
state_dir = os.path.expanduser("~/.local/state/quickshell/agents")
usage_dir = os.path.join(state_dir, "usage")
config_file = os.path.expanduser("~/.config/quickshell/agents/gemini.json")
if not os.path.isfile(config_file):
    legacy_config = os.path.expanduser("~/.config/omarchy/agents/gemini.json")
    if os.path.isfile(legacy_config):
        config_file = legacy_config
history_file = os.path.join(state_dir, "gemini-history.jsonl")
if not os.path.isfile(history_file):
    legacy_hist = os.path.expanduser("~/.local/state/omarchy/agents/gemini-history.jsonl")
    if os.path.isfile(legacy_hist):
        history_file = legacy_hist

os.makedirs(usage_dir, exist_ok=True)

config = {}
if os.path.isfile(config_file):
    try:
        with open(config_file, "r") as f:
            config = json.load(f)
    except Exception:
        pass

now = datetime.datetime.now(datetime.timezone.utc)
local_now = datetime.datetime.now()
today_str = local_now.strftime("%Y-%m-%d")

dates = [(local_now - datetime.timedelta(days=i)).strftime("%Y-%m-%d") for i in range(6, -1, -1)]
recent_tokens = {d: 0 for d in dates}
recent_prompts = {d: 0 for d in dates}

total_prompts = 0
today_prompts = 0
today_sessions_set = set()
all_sessions = set()
active_dates = set()

today_tokens_by_model = {"gemini-2.5-pro": 0, "gemini-2.5-flash": 0}
model_usage = {
    "gemini-2.5-pro": {"inputTokens": 0, "outputTokens": 0, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0},
    "gemini-2.5-flash": {"inputTokens": 0, "outputTokens": 0, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0}
}

transcripts = glob.glob(os.path.join(brain_dir, "*", ".system_generated", "logs", "transcript.jsonl"))

for t_path in transcripts:
    conv_id = os.path.basename(os.path.dirname(os.path.dirname(os.path.dirname(t_path))))
    all_sessions.add(conv_id)
    session_has_today = False
    
    try:
        with open(t_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if not line.strip(): continue
                obj = json.loads(line)
                step_type = obj.get("type", "")
                created = obj.get("created_at", "")
                
                content = obj.get("content", "")
                thinking = obj.get("thinking", "")
                char_count = len(content) + len(thinking)
                step_tokens = max(1, char_count // 4)
                
                date_str = ""
                if created:
                    try:
                        dt = datetime.datetime.fromisoformat(created.replace("Z", "+00:00")).astimezone()
                        date_str = dt.strftime("%Y-%m-%d")
                    except Exception:
                        date_str = created[:10]
                        
                if date_str:
                    active_dates.add(date_str)
                    if date_str in recent_tokens:
                        recent_tokens[date_str] += step_tokens
                    if date_str == today_str:
                        session_has_today = True

                if step_type == "USER_INPUT":
                    total_prompts += 1
                    if date_str == today_str:
                        today_prompts += 1
                    if date_str in recent_prompts:
                        recent_prompts[date_str] += 1
                    model_usage["gemini-2.5-pro"]["inputTokens"] += step_tokens
                    if date_str == today_str:
                        today_tokens_by_model["gemini-2.5-pro"] += step_tokens
                elif step_type in ("MODEL_RESPONSE", "PLANNER_RESPONSE"):
                    model_usage["gemini-2.5-pro"]["outputTokens"] += step_tokens
                    if date_str == today_str:
                        today_tokens_by_model["gemini-2.5-pro"] += step_tokens
                else:
                    model_usage["gemini-2.5-flash"]["inputTokens"] += step_tokens
                    if date_str == today_str:
                        today_tokens_by_model["gemini-2.5-flash"] += step_tokens

        if session_has_today:
            today_sessions_set.add(conv_id)
    except Exception:
        pass

if os.path.isfile(history_file):
    try:
        with open(history_file, "r", encoding="utf-8") as f:
            for line in f:
                if not line.strip(): continue
                item = json.loads(line)
                d = item.get("date", today_str)
                in_tok = item.get("inputTokens", 0)
                out_tok = item.get("outputTokens", 0)
                m = item.get("model", "gemini-2.5-pro")
                if m not in model_usage:
                    model_usage[m] = {"inputTokens": 0, "outputTokens": 0, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0}
                if m not in today_tokens_by_model:
                    today_tokens_by_model[m] = 0
                
                model_usage[m]["inputTokens"] += in_tok
                model_usage[m]["outputTokens"] += out_tok
                tot = in_tok + out_tok
                if d in recent_tokens:
                    recent_tokens[d] += tot
                if d == today_str:
                    today_prompts += 1
                    today_tokens_by_model[m] += tot
                total_prompts += 1
                active_dates.add(d)
    except Exception:
        pass

today_total_tokens = sum(today_tokens_by_model.values())
recent_days = [{"date": d, "messageCount": recent_tokens[d]} for d in dates]

next_session_reset = (now + datetime.timedelta(hours=3)).strftime("%Y-%m-%dT%H:00:00Z")
days_until_sunday = (6 - now.weekday()) % 7 or 7
next_weekly_reset = (now + datetime.timedelta(days=days_until_sunday)).strftime("%Y-%m-%dT00:00:00Z")

session_pct = min(0.95, round(today_prompts / max(1, config.get("sessionLimit", 50)), 2))
weekly_prompts = sum(recent_prompts.values())
weekly_pct = min(0.95, round(weekly_prompts / max(1, config.get("weeklyLimit", 500)), 2))

record = {
    "id": "gemini",
    "name": config.get("name", "Google Gemini"),
    "ready": True,
    "tierLabel": config.get("tier", "Advanced"),
    "usageStatusText": "",
    "authHelpText": "",
    "limits": [
        {
            "label": "Session (5-hour)",
            "percent": session_pct,
            "resetsAt": next_session_reset
        },
        {
            "label": "Weekly (7-day)",
            "percent": weekly_pct,
            "resetsAt": next_weekly_reset
        }
    ],
    "todayPrompts": today_prompts,
    "todaySessions": len(today_sessions_set) or 1,
    "todayTotalTokens": today_total_tokens,
    "todayTokensByModel": today_tokens_by_model,
    "recentDays": recent_days,
    "totalPrompts": total_prompts,
    "totalSessions": len(all_sessions),
    "activeDays": len(active_dates),
    "modelUsage": model_usage
}

out_path = os.path.join(usage_dir, "gemini.json")
tmp_path = out_path + ".tmp"
with open(tmp_path, "w", encoding="utf-8") as f:
    json.dump(record, f, indent=2)
os.replace(tmp_path, out_path)
'';

  omarchyAgentUsageGemini = pkgs.writeShellScriptBin "omarchy-agent-usage-gemini" ''
    exec quickshell-agent-usage-gemini "$@"
  '';

  quickshellAgentUsageUpdate = pkgs.writeShellScriptBin "quickshell-agent-usage-update" ''
    USAGE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/agents/usage"
    mkdir -p "$USAGE_DIR"

    if command -v quickshell-agent-usage-gemini >/dev/null 2>&1; then
      quickshell-agent-usage-gemini "$@" || true
    fi
  '';

  omarchyAgentUsageUpdate = pkgs.writeShellScriptBin "omarchy-agent-usage-update" ''
    exec quickshell-agent-usage-update "$@"
  '';

  quickshellAgent = pkgs.writeShellScriptBin "quickshell-agent" ''
    action="$1"
    if [ "$action" = "--pick" ] || [ -z "$action" ] || [ "$action" = "gemini" ]; then
      if command -v antigravity-ide >/dev/null 2>&1; then
        antigravity-ide "$HOME/Configuration/nixos" &
      fi
    fi
  '';

  omarchyAgent = pkgs.writeShellScriptBin "omarchy-agent" ''
    exec quickshell-agent "$@"
  '';

  agentPackages = [
    quickshellAgentUsageGemini
    omarchyAgentUsageGemini
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
        ExecStart = "${quickshellAgentUsageGemini}/bin/quickshell-agent-usage-gemini";
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

    systemd.user.paths.agent-usage-tracker = {
      Unit = {
        Description = "Watch Antigravity transcript changes for immediate agent metrics update";
      };
      Path = {
        PathModified = "%h/.gemini/antigravity-ide/brain";
        Unit = "agent-usage-tracker.service";
      };
      Install = {
        WantedBy = [ "paths.target" ];
      };
    };
  };
}
