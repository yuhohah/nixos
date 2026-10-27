import json
import math
import subprocess
import sys

HYPRCTL = "@hyprctl@"


def scale_monitor(requested, monitor_name=None):
    scale = float(requested)
    if not math.isfinite(scale) or not 0.5 <= scale <= 4:
        raise ValueError("Scale must be between 0.5 and 4")
    monitors = json.loads(subprocess.check_output([HYPRCTL, "-j", "monitors"], text=True))
    monitor = next((m for m in monitors if
                    (m["name"] == monitor_name if monitor_name else m.get("focused"))), None)
    if not monitor:
        raise ValueError("No active monitor selected")
    # Hyprland requires integral logical dimensions on its 1/120 scale grid.
    divisor = math.gcd(round(monitor["width"] * 120), round(monitor["height"] * 120))
    units = min(round(scale * 120), divisor)
    while divisor % units:
        units += 1
    scale = units / 120
    mode = f'{monitor["width"]}x{monitor["height"]}@{monitor["refreshRate"]}'
    position = f'{monitor["x"]}x{monitor["y"]}'
    quote = lambda value: json.dumps(str(value), ensure_ascii=False)
    rule = (f'hl.monitor({{output = {quote(monitor["name"])}, mode = {quote(mode)}, '
            f'position = {quote(position)}, scale = {quote(scale)}}})')
    response = subprocess.check_output([HYPRCTL, "eval", rule], text=True).strip()
    # hyprctl can return status 0 even when the compositor rejects the rule.
    if response != "ok":
        raise RuntimeError(response)


if __name__ == "__main__":
    try:
        scale_monitor(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
    except (IndexError, ValueError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"monitor-scaling: {error}", file=sys.stderr)
        sys.exit(1)
