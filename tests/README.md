Run the collector and display helper regression tests with Python's standard library:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p 'test_*.py'
```

The integration check requires a running Hyprland session. With two monitors it also checks that IPC handlers register once and popups open on the focused monitor. It launches a temporary shell, briefly displays its panels, and checks live text-size updates and standalone panel loading. HOME and state are isolated; GTK setting changes are stubbed.

Build and check each host's configuration:

```sh
for host in nixos-btw arrow; do
  config=$(nix build --no-link --print-out-paths ".#nixosConfigurations.$host.config.home-manager.users.luan.xdg.configFile.quickshell.source")
  python3 tests/check_quickshell.py --source "$config" --host "$host"
done
```

The T3 Code collector reads `~/.t3/userdata/statev2.sqlite` in read-only mode, falling back to `state.sqlite` for older prompt/session counts. Override the directory with `T3CODE_USERDATA_DIR`. It uses T3's saved per-turn token snapshots; these do not represent account quotas or a complete billing ledger. It reads message roles and timestamps, not prompt text, and writes records under `$XDG_STATE_HOME/quickshell/agents/usage` (default `~/.local/state`).
