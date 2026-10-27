"""Read T3's local projections without reading prompts, credentials or logs."""
import collections
import datetime as dt
import json
import os
from pathlib import Path
import sqlite3
import sys
import tempfile


def local_date(timestamp):
    try:
        return dt.datetime.fromisoformat(timestamp.replace("Z", "+00:00")).astimezone().date().isoformat()
    except (ValueError, TypeError, AttributeError):
        return None


def collect(userdata, now=None):
    today = (now or dt.datetime.now().astimezone()).date()
    dates = [(today - dt.timedelta(days=i)).isoformat() for i in range(6, -1, -1)]
    record = dict(id="t3code", name="T3 Code", ready=False, limits=[], tierLabel="Local",
                  usageStatusText="Dados locais do T3 Code; sem cota da conta.",
                  todayPrompts=0, totalPrompts=0, todaySessions=0, totalSessions=0,
                  activeDays=0, todayTotalTokens=0, todayTokensByModel={}, modelUsage={},
                  recentDays=[dict(date=d, messageCount=0) for d in dates])
    database = Path(userdata) / "statev2.sqlite"
    if not database.is_file():
        database = Path(userdata) / "state.sqlite"
    if not database.is_file():
        return record
    with sqlite3.connect(database.resolve().as_uri() + "?mode=ro", uri=True, timeout=2) as db:
        db.execute("PRAGMA query_only = ON")
        tables = {r[0] for r in db.execute("SELECT name FROM sqlite_master WHERE type='table'")}
        v2 = "orchestration_v2_projection_messages" in tables
        messages = "orchestration_v2_projection_messages" if v2 else "projection_thread_messages"
        sessions = set()
        today_sessions = set()
        active_dates = set()
        for thread, timestamp in db.execute(f"SELECT thread_id, created_at FROM {messages} WHERE role = 'user'"):
            day = local_date(timestamp)
            sessions.add(thread)
            if day:
                active_dates.add(day)
            record["totalPrompts"] += 1
            if day == today.isoformat():
                record["todayPrompts"] += 1
                today_sessions.add(thread)
        record.update(totalSessions=len(sessions), todaySessions=len(today_sessions),
                      activeDays=len(active_dates), ready=True)
        if not v2:
            record["usageStatusText"] = "Histórico local do T3 Code; tokens indisponíveis nesta versão."
            return record
        daily_tokens = collections.Counter()
        # One row per native turn: retries and repeated polls never append
        # duplicate usage. Cached input is part of inputTokens, not extra input.
        query = '''SELECT t.started_at,
                   json_extract(t.payload_json, '$.tokenUsage'),
                   json_extract(r.payload_json, '$.modelSelection.model')
                   FROM orchestration_v2_projection_provider_turns t
                   LEFT JOIN orchestration_v2_projection_run_attempts a
                     ON a.attempt_id = json_extract(t.payload_json, '$.runAttemptId')
                   LEFT JOIN orchestration_v2_projection_runs r ON r.run_id = a.run_id
                   WHERE json_extract(t.payload_json, '$.tokenUsage') IS NOT NULL'''
        for timestamp, raw_usage, model in db.execute(query):
            usage = json.loads(raw_usage)
            def count(key):
                value = usage.get(key)
                return max(0, int(value)) if isinstance(value, (int, float)) else 0
            inputs = count("inputTokens")
            cached = min(inputs, count("cachedInputTokens"))
            outputs = count("outputTokens")
            model = model or "unknown"
            bucket = record["modelUsage"].setdefault(model, dict(inputTokens=0, outputTokens=0,
                        cacheReadInputTokens=0, cacheCreationInputTokens=0))
            bucket["inputTokens"] += inputs - cached
            bucket["cacheReadInputTokens"] += cached
            bucket["outputTokens"] += outputs
            day = local_date(timestamp)
            daily_tokens[day] += inputs + outputs
            if day == today.isoformat():
                record["todayTokensByModel"][model] = record["todayTokensByModel"].get(model, 0) + inputs + outputs
        record["todayTotalTokens"] = sum(record["todayTokensByModel"].values())
        record["recentDays"] = [dict(date=d, messageCount=daily_tokens[d]) for d in dates]
        record["usageStatusText"] = "Tokens reportados por turno pelo T3 Code; sem cota da conta."
    return record


def publish(record, state_home):
    directory = Path(state_home) / "quickshell/agents/usage"
    directory.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", dir=directory, prefix=".t3code-", suffix=".tmp", delete=False) as file:
            temporary = Path(file.name)
            json.dump(record, file, ensure_ascii=False, indent=2)
        temporary.replace(directory / "t3code.json")
    finally:
        if temporary:
            temporary.unlink(missing_ok=True)


if __name__ == "__main__":
    try:
        userdata = Path(os.environ.get("T3CODE_USERDATA_DIR", str(Path.home() / ".t3/userdata")))
        state_home = Path(os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state")))
        publish(collect(userdata), state_home)
    except (sqlite3.Error, OSError, ValueError) as error:
        print(f"agents t3code: {error}", file=sys.stderr)
        sys.exit(1)
