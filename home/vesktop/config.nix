{ config, pkgs, ... }:

{
  # ========================================
  # CONFIGURAÇÃO DO VESKTOP
  # ========================================
  
  # Configuração do Vesktop com flags corretas para Wayland
  home.file.".config/vesktop-flags.conf".text = ''
    --enable-features=WaylandWindowDecorations
    --ozone-platform-hint=auto
    --enable-webrtc-pipewire-capturer
    --enable-features=WebRTCPipeWireCapturer
  '';

  # Script wrapper para iniciar Vesktop com as flags corretas
  home.file.".local/bin/vesktop-wayland" = {
    text = ''
      #!/usr/bin/env bash
      exec vesktop \
        --enable-features=WaylandWindowDecorations \
        --ozone-platform-hint=auto \
        --enable-webrtc-pipewire-capturer \
        --enable-features=WebRTCPipeWireCapturer \
        "$@"
    '';
    executable = true;
  };

  # Configuração adicional do Vesktop
  home.file.".config/vesktop/settings.json".text = builtins.toJSON {
    # Habilita compartilhamento de áudio
    audioSharingEnabled = true;
    
    # Usa PipeWire para captura
    preferredCaptureDevice = "pipewire";
    
    # Outras configurações úteis
    minimizeToTray = true;
    discordBranch = "stable";
  };
}