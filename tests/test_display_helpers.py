"""Text size must work with Home Manager's read-only config directory."""
import os
from pathlib import Path
import subprocess
import shutil
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]


class TextSizeTest(unittest.TestCase):
    def test_writes_mutable_state_and_validates_input(self):
        source = (REPO / "home/scripts/desktop-helpers.nix").read_text()
        script = source.split('displayTextSize = pkgs.writeShellScriptBin "display-text-size" \'\'', 1)[1].split("\n  '';", 1)[0]
        script = script.replace("''${", "${").replace("${pkgs.gawk}/bin/awk", shutil.which("awk"))
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            (home / ".config").mkdir()
            # The real deployed config is a symlink into this immutable store.
            (home / ".config/quickshell").symlink_to(Path.home() / ".config/quickshell")
            (home / "bin").mkdir()
            stub = home / "bin/gsettings"
            stub.write_text("#!/bin/sh\nexit 0\n")
            stub.chmod(0o755)
            env = dict(os.environ, HOME=str(home), XDG_STATE_HOME=str(home / "state"),
                       PATH=str(home / "bin") + ":" + os.environ["PATH"])
            result = subprocess.run(["bash", "-e", "-c", script, "--", "16"], env=env,
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            target = home / "state/quickshell/shell.toml"
            self.assertIn("base-size = 16", target.read_text())
            for value in ["0", "-1", "21", "abc", "12\n[bar]"]:
                result = subprocess.run(["bash", "-e", "-c", script, "--", value], env=env,
                                        capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0, value)
            self.assertIn("base-size = 16", target.read_text())


if __name__ == "__main__":
    unittest.main()
