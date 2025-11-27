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
  # XDG DESKTOP PORTAL (para screen sharing)
  # ========================================
  
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "hyprland" "gtk" ];
      };
      hyprland = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  # Variáveis de ambiente para o portal
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  # ========================================
  # REALTIME AUDIO (opcional, melhora latência)
  # ========================================
  
  security.rtkit.enable = true;
}

