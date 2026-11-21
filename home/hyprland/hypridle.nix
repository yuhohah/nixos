{ config, lib, ... }:

let
  cfg = config.my.hypridle;

  screensaverOnTimeout =
    if cfg.dimOnIdle
    then "brightnessctl set ${cfg.dimLevel} && hyprctl keyword cursor:inactive_timeout 0.1 && run-screensaver"
    else "hyprctl keyword cursor:inactive_timeout 0.1 && run-screensaver";

  screensaverOnResume =
    if cfg.dimOnIdle
    then "brightnessctl set ${cfg.resumeBrightness} && hyprctl keyword cursor:inactive_timeout 0 && pkill -f 'alacritty.*screensaver'"
    else "hyprctl keyword cursor:inactive_timeout 0 && pkill -f 'alacritty.*screensaver'";
in
{
  options.my.hypridle = {
    screensaverTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 1500;
      description = "Idle timeout (seconds) before starting screensaver.";
    };
    lockTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 2500;
      description = "Idle timeout (seconds) before locking session and turning DPMS off.";
    };
    suspendTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 35000;
      description = "Idle timeout (seconds) before suspending the system.";
    };
    dimOnIdle = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Dim screen backlight via brightnessctl when entering screensaver.";
    };
    dimLevel = lib.mkOption {
      type = lib.types.str;
      default = "10%";
      description = "Brightness level applied when dimOnIdle triggers.";
    };
    resumeBrightness = lib.mkOption {
      type = lib.types.str;
      default = "60%";
      description = "Brightness level restored on resume when dimOnIdle is enabled.";
    };
  };

  config = {
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          # Tempo antes de travar (em segundos)
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            ignore_inhibit = true;
            timeout = cfg.screensaverTimeout;
            on-timeout = screensaverOnTimeout;
            on-resume = screensaverOnResume;
          }
          {
            timeout = cfg.lockTimeout;
            on-timeout = "loginctl lock-session; hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = cfg.suspendTimeout;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}