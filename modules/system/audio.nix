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
  };

  # ========================================
  # REALTIME AUDIO (opcional, melhora latência)
  # ========================================
  
  security.rtkit.enable = true;
}

