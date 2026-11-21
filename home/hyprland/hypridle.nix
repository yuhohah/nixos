{ config, lib, ... }:

let
  cfg = config.my.hypridle;

  screensaverOnTimeout =
    if cfg.dimOnIdle
    then "brightnessctl -s set ${cfg.dimLevel}; run-screensaver"
    else "run-screensaver";

  screensaverOnResume =
    if cfg.dimOnIdle
    then "brightnessctl -r || brightnessctl set ${cfg.resumeBrightness}; stop-screensaver"
    else "stop-screensaver";
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
      description = "Idle timeout (seconds) before locking session.";
    };
    dpmsTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = cfg.lockTimeout + 30;
      defaultText = lib.literalExpression "config.my.hypridle.lockTimeout + 30";
      description = "Idle timeout (seconds) before turning monitors off via DPMS (runs after lock).";
    };
    suspendTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 35000;
      description = "Idle timeout (seconds) before suspending the system.";
    };
    ignoreInhibit = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Ignore idle inhibit locks consistently across screensaver, lock, DPMS and suspend.";
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
      description = "Fallback brightness level restored on resume when dimOnIdle is enabled.";
    };
  };

  config = {
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          # Garante encerramento do screensaver antes de travar e aguarda lock antes de suspender
          lock_cmd = "stop-screensaver; pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          inhibit_sleep = 3;
        };

        listener = [
          {
            ignore_inhibit = cfg.ignoreInhibit;
            timeout = cfg.screensaverTimeout;
            on-timeout = screensaverOnTimeout;
            on-resume = screensaverOnResume;
          }
          {
            ignore_inhibit = cfg.ignoreInhibit;
            timeout = cfg.lockTimeout;
            on-timeout = "loginctl lock-session";
          }
          {
            ignore_inhibit = cfg.ignoreInhibit;
            timeout = cfg.dpmsTimeout;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            ignore_inhibit = cfg.ignoreInhibit;
            timeout = cfg.suspendTimeout;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}