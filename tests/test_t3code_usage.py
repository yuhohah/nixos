import datetime as dt
import importlib.util
import json
from pathlib import Path
import sqlite3
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("t3_usage", Path(__file__).resolve().parents[1] / "home/scripts/agent-usage-t3code.py")
usage = importlib.util.module_from_spec(spec)
spec.loader.exec_module(usage)
NOW = dt.datetime.fromisoformat("2026-10-27T12:00:00+00:00").astimezone()


class T3UsageTest(unittest.TestCase):
    def test_local_turns_are_counted_once_and_cache_is_not_double_counted(self):
        with tempfile.TemporaryDirectory() as directory:
            database = Path(directory) / "statev2.sqlite"
            with sqlite3.connect(database) as db:
                db.executescript('''
                  CREATE TABLE orchestration_v2_projection_messages (thread_id, created_at, role);
                  CREATE TABLE orchestration_v2_projection_provider_turns (started_at, payload_json);
                  CREATE TABLE orchestration_v2_projection_run_attempts (attempt_id, run_id);
                  CREATE TABLE orchestration_v2_projection_runs (run_id, payload_json);
                ''')
                db.executemany("INSERT INTO orchestration_v2_projection_messages VALUES (?, ?, ?)", [
                    ("thread-1", NOW.isoformat(), "user"),
                    ("thread-1", NOW.isoformat(), "assistant"),
                    ("thread-1", NOW.isoformat(), "user")])
                db.execute("INSERT INTO orchestration_v2_projection_run_attempts VALUES ('attempt', 'run')")
                db.execute("INSERT INTO orchestration_v2_projection_runs VALUES (?, ?)",
                           ("run", json.dumps(dict(modelSelection=dict(model="test-model")))))
                db.execute("INSERT INTO orchestration_v2_projection_provider_turns VALUES (?, ?)",
                           (NOW.isoformat(), json.dumps(dict(runAttemptId="attempt", tokenUsage=dict(
                               inputTokens=1000, cachedInputTokens=800, outputTokens=100, reasoningOutputTokens=50)))))
            first = usage.collect(directory, NOW)
            second = usage.collect(directory, NOW)
            self.assertEqual(first, second)
            self.assertEqual(first["totalPrompts"], 2)
            self.assertEqual(first["todaySessions"], 1)
            self.assertEqual(first["todayTotalTokens"], 1100)
            self.assertEqual(first["modelUsage"]["test-model"], dict(inputTokens=200,
                cacheReadInputTokens=800, outputTokens=100, cacheCreationInputTokens=0))
            self.assertEqual(first["limits"], [])
            usage.publish(first, Path(directory) / "state")
            usage.publish(second, Path(directory) / "state")
            output = Path(directory) / "state/quickshell/agents/usage"
            self.assertEqual(json.loads((output / "t3code.json").read_text()), first)
            self.assertEqual(len(list(output.iterdir())), 1)

    def test_missing_database_does_not_create_one_or_invent_sessions(self):
        with tempfile.TemporaryDirectory() as directory:
            record = usage.collect(directory, NOW)
            self.assertFalse(record["ready"])
            self.assertEqual(record["totalSessions"], 0)
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_legacy_database_has_prompt_counts_without_invented_tokens(self):
        with tempfile.TemporaryDirectory() as directory:
            with sqlite3.connect(Path(directory) / "state.sqlite") as db:
                db.execute("CREATE TABLE projection_thread_messages (thread_id, created_at, role)")
                db.execute("INSERT INTO projection_thread_messages VALUES ('thread', ?, 'user')", (NOW.isoformat(),))
            record = usage.collect(directory, NOW)
            self.assertEqual(record["todayPrompts"], 1)
            self.assertEqual(record["todayTotalTokens"], 0)


if __name__ == "__main__":
    unittest.main()
