{ config, lib, ... }:
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

      # Baixa latência estável para desktop/jogos (evita underruns de 32/48000); poupa CPU/bateria no notebook
      extraConfig.pipewire-pulse = lib.mkIf (!config.my.roles.laptop.enable) {
        "92-low-latency" = {
          "pulse.properties" = {
            "pulse.min.req" = "128/48000";
            "pulse.default.req" = "128/48000";
            "pulse.max.req" = "1024/48000";
            "pulse.min.quantum" = "128/48000";
          };
        };
      };
    };

    security.rtkit.enable = true;
  };
}
