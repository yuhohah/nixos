{ config, lib, pkgs, ... }:
{
  options.my.system.audio.enable = lib.mkEnableOption "Audio Config";

  config = lib.mkIf config.my.system.audio.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      wireplumber.enable = true;

      extraConfig.pipewire-pulse."92-low-latency" = {
        "pulse.properties" = {
          "pulse.min.req" = "32/48000";
          "pulse.default.req" = "32/48000";
          "pulse.max.req" = "32/48000";
          "pulse.min.quantum" = "32/48000";
        };
      };
    };

    security.rtkit.enable = true;
  };
}
