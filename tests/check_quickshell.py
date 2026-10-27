"""Integration check for a running Hyprland session with multiple monitors.

Usage: python3 tests/check_quickshell.py --source /nix/store/...-quickshell-config
Copies the configuration into a temporary HOME; never writes the live config.
"""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time

REPO = Path(__file__).resolve().parents[1]


def run(*args):
    return subprocess.check_output(args, text=True, stderr=subprocess.STDOUT, timeout=10)


def check(source, host):
    with tempfile.TemporaryDirectory(prefix="quickshell-regression-") as directory:
        home = Path(directory)
        config = home / ".config/quickshell"
        shutil.copytree(source, config)
        config.chmod(config.stat().st_mode | 0o200)
        (config / "shell.json").unlink(missing_ok=True)
        shutil.copyfile(REPO / f"home/quickshell/hosts/{host}/shell.json", config / "shell.json")
        assert (config / "bin/monitor-scaling").is_file(), "Pass the Nix-built configuration, including helpers"
        # Query actual popup instances, without adding a diagnostics API to
        # the shipped shell. This catches successful IPC calls that route to
        # the wrong monitor as well as duplicate registrations.
        qml = config / "shell.qml"
        qml.chmod(qml.stat().st_mode | 0o200)
        text = qml.read_text()
        probe = '''
  Item { id: regressionHost }
  IpcHandler {
    target: "regression"
    function textSize(): string { return String(Style.font.baseSize) }
    function setTextSize(px: string): void { shell.bar.findPanelWidget("monitor").setTextSize(Number(px)) }
    function loadPanel(id: string): string {
      var manifest = shell.pluginRegistry.installedPlugins[id]
      var url = shell.pluginRegistry.entryPointUrl(manifest, "panel")
      var component = Qt.createComponent(url, Component.PreferSynchronous)
      if (component.status !== Component.Ready) return component.errorString()
      var panel = component.createObject(regressionHost)
      if (!panel) return "createObject failed"
      panel.destroy()
      return "ok"
    }
    function openedScreens(id: string): string {
      var slots = shell.bar.moduleSlots
      var result = []
      for (var i = 0; i < slots.length; i++) {
        var slot = slots[i]
        if (slot.moduleName === id && slot.activeItem && slot.activeItem.opened)
          result.push(shell.bar.slotScreenName(slot))
      }
      return JSON.stringify(result)
    }
  }
'''
        end = text.rfind("}")
        qml.write_text(text[:end] + probe + text[end:])
        env = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(home / ".config"),
                   XDG_STATE_HOME=str(home / ".local/state"), OMARCHY_PATH=str(config))
        # GTK settings are outside the shell's isolated state; keep the test
        # focused on shell typography without changing the user's desktop.
        stub_bin = home / "test-bin"
        stub_bin.mkdir()
        (stub_bin / "gsettings").write_text("#!/bin/sh\nexit 0\n")
        (stub_bin / "gsettings").chmod(0o755)
        env["PATH"] = str(stub_bin) + ":" + env["PATH"]
        state = home / ".local/state/quickshell/agents/usage"
        state.mkdir(parents=True)
        (state / "t3code.json").write_text(json.dumps(dict(id="t3code", name="T3 Code",
            ready=True, totalPrompts=2, totalSessions=1, todayTotalTokens=1100, limits=[])))
        with (home / "runtime.log").open("w+") as log:
            process = subprocess.Popen(["quickshell", "--no-color", "-p", str(config)],
                                       env=env, stdout=log, stderr=log)
            def ipc(*args):
                return run("quickshell", "ipc", "-p", str(config), *args).strip()
            try:
                targets = ["agents", "audio", "bluetooth", "clock", "monitor", "network"]
                if host == "arrow":
                    targets.append("power")
                deadline = time.monotonic() + 15
                while True:
                    assert process.poll() is None, "shell exited during startup"
                    try:
                        listing = ipc("show")
                        if all(f"target {target}\n" in listing for target in targets):
                            break
                    except subprocess.CalledProcessError:
                        pass
                    assert time.monotonic() < deadline, "IPC targets did not become ready"
                    time.sleep(0.1)
                for target in targets:
                    ipc("call", target, "open")
                    if target != "power":  # Battery popup stays closed on desktops.
                        monitors = json.loads(run("hyprctl", "monitors", "-j"))
                        focused = next(m["name"] for m in monitors if m["focused"])
                        opened = json.loads(ipc("call", "regression", "openedScreens", target))
                        assert opened == [focused], (target, opened, focused)
                    ipc("call", target, "close")
                    assert json.loads(ipc("call", "regression", "openedScreens", target)) == []
                ipc("call", "agents", "next")
                ipc("call", "agents", "open")
                ipc("call", "agents", "close")
                ipc("call", "regression", "setTextSize", "16")
                deadline = time.monotonic() + 5
                while ipc("call", "regression", "textSize") != "16":
                    assert time.monotonic() < deadline, "text size did not apply live"
                    time.sleep(0.05)
                for target in ["wifiqr", "speedtest", "disk-speedtest"]:
                    result = ipc("call", "regression", "loadPanel", target)
                    assert result == "ok", (target, result)
                time.sleep(0.3)
            finally:
                process.terminate()
                process.wait(timeout=10)
                log.seek(0)
                output = log.read()
                errors = [line for line in output.splitlines() if
                          "ERROR" in line or "WARN scene:" in line or "WARN qml:" in line
                          or "ReferenceError" in line or "TypeError" in line]
                if errors:
                    raise AssertionError("\n".join(errors))
        print(f"{host}: IPC targets unique; panels route correctly; text size updates live; standalone panels load")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--host", choices=["nixos-btw", "arrow"])
    args = parser.parse_args()
    for host in [args.host] if args.host else ["nixos-btw", "arrow"]:
        check(args.source, host)
