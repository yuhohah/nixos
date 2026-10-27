import importlib.util
from pathlib import Path
import unittest
from unittest.mock import patch
import json

spec = importlib.util.spec_from_file_location("scaling", Path(__file__).resolve().parents[1] / "home/scripts/monitor-scaling.py")
scaling = importlib.util.module_from_spec(spec)
spec.loader.exec_module(scaling)


class MonitorScalingTest(unittest.TestCase):
    def test_lua_rule_preserves_mode_and_position_and_cleans_fraction(self):
        monitors = [dict(name="HDMI-A-1", focused=True, width=1920, height=1080,
                         refreshRate=144, x=0, y=0),
                    dict(name="HDMI-A-2", focused=False, width=1366, height=768,
                         refreshRate=75, x=1920, y=0)]
        with patch.object(scaling.subprocess, "check_output", side_effect=[json.dumps(monitors), "ok\n"]) as command:
            scaling.scale_monitor("1.25", "HDMI-A-2")
        self.assertEqual(command.call_args.args[0][1:], ["eval",
            'hl.monitor({output = "HDMI-A-2", mode = "1366x768@75", position = "1920x0", scale = "2.0"})'])

    def test_invalid_scale_never_calls_compositor(self):
        for value in ["0", "-1", "nan", "inf", "5", "abc"]:
            with patch.object(scaling.subprocess, "check_output") as command:
                with self.assertRaises(ValueError):
                    scaling.scale_monitor(value)
                command.assert_not_called()

    def test_compositor_rejection_is_not_silently_accepted(self):
        monitors = [dict(name="eDP-1", focused=True, width=1920, height=1080,
                         refreshRate=60, x=0, y=0)]
        with patch.object(scaling.subprocess, "check_output", side_effect=[json.dumps(monitors), "invalid monitor rule"]):
            with self.assertRaisesRegex(RuntimeError, "invalid monitor rule"):
                scaling.scale_monitor("1.25")


if __name__ == "__main__":
    unittest.main()
