{ lib, pkgs, ... }:

let
  quickshellAgentUsageGemini = pkgs.writeScriptBin "quickshell-agent-usage-gemini" ''#!${pkgs.python3}/bin/python3
import os, sys, glob, json, datetime, sqlite3, re

brain_patterns = [
    os.path.expanduser("~/.gemini/*/brain"),
]
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

now_utc = datetime.datetime.now(datetime.timezone.utc)
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
prompt_timestamps = []

today_tokens_by_model = {}
model_usage = {}

def get_models_for_conv(conv_db_path):
    if not os.path.isfile(conv_db_path):
        return {}, "gemini-3.8-flash"
    try:
        conn = sqlite3.connect(conv_db_path)
        c = conn.cursor()
        c.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='executor_metadata';")
        if not c.fetchone():
            return {}, "gemini-3.8-flash"
        c.execute("SELECT idx, data FROM executor_metadata ORDER BY idx")
        mapping = {}
        last_model = "gemini-3.8-flash"
        for idx, data in c.fetchall():
            found = re.findall(rb'((?:gemini|claude|gpt)-[a-zA-Z0-9\._-]+)', data)
            models = [f.decode('latin1') for f in found if not any(x in f.decode('latin1') for x in ['handoff', 'sandbox', 'proxy', 'tools', 'code'])]
            if models:
                mapping[idx] = models[0]
                last_model = models[0]
        return mapping, last_model
    except Exception:
        return {}, "gemini-3.8-flash"

brain_dirs = []
for p in brain_patterns:
    brain_dirs.extend(glob.glob(p))

transcripts = []
for bd in brain_dirs:
    transcripts.extend(glob.glob(os.path.join(bd, "*", ".system_generated", "logs", "transcript.jsonl")))

for t_path in transcripts:
    parts = t_path.split(os.sep)
    conv_id = parts[-4]
    app_name = parts[-6]
    all_sessions.add(conv_id)
    session_has_today = False
    
    db_path = os.path.expanduser(f"~/.gemini/{app_name}/conversations/{conv_id}.db")
    mapping, default_model = get_models_for_conv(db_path)
    user_idx = 0

    try:
        with open(t_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if not line.strip(): continue
                try:
                    obj = json.loads(line)
                except Exception:
                    continue
                
                stype = obj.get("type", "")
                created = obj.get("created_at", "")
                
                dt_obj = None
                date_str = ""
                if created:
                    try:
                        dt_obj = datetime.datetime.fromisoformat(created.replace("Z", "+00:00")).astimezone()
                        date_str = dt_obj.strftime("%Y-%m-%d")
                    except Exception:
                        date_str = created[:10]

                if date_str:
                    active_dates.add(date_str)
                    if date_str == today_str:
                        session_has_today = True

                if stype == "USER_INPUT":
                    user_idx += 1
                    total_prompts += 1
                    if dt_obj:
                        prompt_timestamps.append(dt_obj)
                    if date_str == today_str:
                        today_prompts += 1
                    if date_str in recent_prompts:
                        recent_prompts[date_str] += 1

                curr_model = mapping.get(user_idx, default_model)
                if curr_model not in model_usage:
                    model_usage[curr_model] = {"inputTokens": 0, "outputTokens": 0, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0}
                if curr_model not in today_tokens_by_model:
                    today_tokens_by_model[curr_model] = 0

                has_tok = any(k in obj for k in ("input_tokens", "output_tokens", "cache_read_tokens"))
                if has_tok:
                    in_tok = obj.get("input_tokens", 0) or 0
                    out_tok = obj.get("output_tokens", 0) or 0
                    cache_tok = obj.get("cache_read_tokens", 0) or 0
                else:
                    content = obj.get("content", "")
                    thinking = obj.get("thinking", "")
                    step_tok = max(1, (len(content) + len(thinking)) // 4)
                    if stype == "USER_INPUT":
                        in_tok = step_tok
                        out_tok = 0
                    else:
                        in_tok = 0
                        out_tok = step_tok
                    cache_tok = 0

                step_tot = in_tok + out_tok + cache_tok
                model_usage[curr_model]["inputTokens"] += in_tok
                model_usage[curr_model]["outputTokens"] += out_tok
                model_usage[curr_model]["cacheReadInputTokens"] += cache_tok

                if date_str in recent_tokens:
                    recent_tokens[date_str] += step_tot
                if date_str == today_str:
                    today_tokens_by_model[curr_model] += step_tot

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
                m = item.get("model", "gemini-3.8-flash")
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

# Clean up models with 0 today tokens
today_tokens_by_model = {m: tok for m, tok in today_tokens_by_model.items() if tok > 0}

# Session calculation (5-hour window)
cutoff_5h = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(hours=5)
prompts_5h = [t for t in prompt_timestamps if t.astimezone(datetime.timezone.utc) >= cutoff_5h]

if prompts_5h:
    first_prompt_5h = min(prompts_5h)
    session_reset_dt = first_prompt_5h + datetime.timedelta(hours=5)
    next_session_reset = session_reset_dt.astimezone(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    session_pct = min(0.95, round(len(prompts_5h) / max(1, config.get("sessionLimit", 50)), 2))
else:
    session_pct = 0.0
    next_session_reset = ""

# Daily calculation (local midnight)
local_midnight = local_now.replace(hour=0, minute=0, second=0, microsecond=0) + datetime.timedelta(days=1)
next_daily_reset = local_midnight.astimezone(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
daily_limit = config.get("dailyLimit", config.get("sessionLimit", 100))
daily_pct = min(0.95, round(today_prompts / max(1, daily_limit), 2))

# Weekly calculation (next Sunday midnight)
days_to_sunday = (6 - local_now.weekday()) % 7
if days_to_sunday == 0:
    days_to_sunday = 7
sunday_midnight = local_now.replace(hour=0, minute=0, second=0, microsecond=0) + datetime.timedelta(days=days_to_sunday)
next_weekly_reset = sunday_midnight.astimezone(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
weekly_prompts = sum(recent_prompts.values())
weekly_limit = config.get("weeklyLimit", 500)
weekly_pct = min(0.95, round(weekly_prompts / max(1, weekly_limit), 2))

limits = [
    {
        "title": "Session",
        "label": "Session (5-hour)",
        "percent": session_pct,
        "resetsAt": next_session_reset
    },
    {
        "title": "Daily",
        "label": "Daily (24-hour)",
        "percent": daily_pct,
        "resetsAt": next_daily_reset
    },
    {
        "title": "Weekly",
        "label": "Weekly (7-day)",
        "percent": weekly_pct,
        "resetsAt": next_weekly_reset
    }
]

record = {
    "id": "gemini",
    "name": config.get("name", "Google Gemini"),
    "ready": True,
    "tierLabel": config.get("tier", "Advanced"),
    "usageStatusText": "",
    "authHelpText": "",
    "limits": limits,
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
        PathModified = "%h/.gemini";
        Unit = "agent-usage-tracker.service";
      };
      Install = {
        WantedBy = [ "paths.target" ];
      };
    };
  };
}
