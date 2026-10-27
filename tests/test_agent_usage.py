"""Run the actual Gemini collector with two writers finishing together."""
import concurrent.futures
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


class GeminiUsageTest(unittest.TestCase):
    def test_concurrent_collectors_publish_complete_records(self):
        source = (Path(__file__).resolve().parents[1] / "home/scripts/agent-usage.nix").read_text()
        source = source.split("import os, sys", 1)[1].split("\n'';", 1)[0]
        source = "import os, sys" + source
        with tempfile.TemporaryDirectory() as directory:
            # Hold both writers immediately before rename so the shared-temp
            # race is deterministic, even with empty transcript directories.
            prelude = '''import os, pathlib, time
original_replace = os.replace
def synchronized_replace(src, dst):
    pathlib.Path(os.environ["HOME"], "ready-" + str(os.getpid())).touch()
    deadline = time.monotonic() + 5
    while len(list(pathlib.Path(os.environ["HOME"]).glob("ready-*"))) < 2:
        if time.monotonic() > deadline:
            raise TimeoutError("second collector did not reach rename")
        time.sleep(0.01)
    original_replace(src, dst)
os.replace = synchronized_replace
'''
            env = dict(os.environ, HOME=directory, XDG_STATE_HOME=str(Path(directory) / ".local/state"))
            def collect(_):
                return subprocess.run(["python3", "-c", prelude + source], env=env,
                                      capture_output=True, text=True, timeout=10)
            with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
                results = list(pool.map(collect, range(2)))
            for result in results:
                self.assertEqual(result.returncode, 0, result.stderr)
            usage = Path(directory) / ".local/state/quickshell/agents/usage"
            self.assertEqual(json.loads((usage / "gemini.json").read_text())["id"], "gemini")
            self.assertEqual([p.name for p in usage.iterdir()], ["gemini.json"])


if __name__ == "__main__":
    unittest.main()
