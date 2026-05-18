{ config, lib, pkgs, ... }:

let
  batteryAlert = pkgs.writeShellScriptBin "battery-alert" ''
    STATE_FILE="/tmp/battery_alert_state"
    touch "$STATE_FILE"

    BATTERY_PATH=$(find /sys/class/power_supply/ -name "BAT*" | head -n 1)

    if [ -z "$BATTERY_PATH" ]; then
      exit 1
    fi

    while true; do
      if [ -f "$BATTERY_PATH/capacity" ]; then
        read -r CAPACITY < "$BATTERY_PATH/capacity"
        read -r STATUS < "$BATTERY_PATH/status"

        if [ "$STATUS" = "Discharging" ]; then
          if [ "$CAPACITY" -le 10 ]; then
            if ! grep -q "10" "$STATE_FILE"; then
              ${pkgs.libnotify}/bin/notify-send -u critical "🪫 Battery Critical!" "Status: ''${CAPACITY}%"
              echo "10" > "$STATE_FILE"
            fi
          elif [ "$CAPACITY" -le 20 ]; then
            if ! grep -q "20" "$STATE_FILE"; then
              ${pkgs.libnotify}/bin/notify-send -u normal "🔋 Battery Low!" "Status: ''${CAPACITY}%"
              echo "20" > "$STATE_FILE"
            fi
          fi
        else
          > "$STATE_FILE"
        fi
      fi

      sleep 60
    done
  '';
in
{
  home.packages = [ batteryAlert ];

  systemd.user.services.battery-alert = {
    Unit = {
      Description = "Batery Monitor";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${batteryAlert}/bin/battery-alert";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
