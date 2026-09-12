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
      wireplumber = {
        enable = true;
        extraConfig."10-bluez" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "hsp_hs" "hfp_hf" ];
          };
        };
      };

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
