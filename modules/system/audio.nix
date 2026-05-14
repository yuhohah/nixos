{ pkgs, ... }:
{
  # ========================================
  # PIPEWIRE - SERVIDOR DE ÁUDIO
  # ========================================
  
  services.pipewire = {
    enable = true;
    
    # Habilita PulseAudio compatibility
    pulse.enable = true;
    
    # Habilita ALSA support
    alsa = {
      enable = true;
      support32Bit = true;
    };
    
    # Habilita JACK support (para aplicações de áudio profissional)
    jack.enable = true;
    
    # WirePlumber (gerenciador de sessão)
    wireplumber.enable = true;

    # Isso impede que o PipeWire tente mudar as configurações enquanto o jogo roda
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
}

