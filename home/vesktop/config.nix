{ config, pkgs, ... }:

{ 
  home.file.".config/vesktop-flags.conf".text = ''
    --enable-features=WaylandWindowDecorations
    --ozone-platform-hint=auto
    --enable-webrtc-pipewire-capturer
    --enable-features=WebRTCPipeWireCapturer
  '';

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

  home.file.".config/vesktop/settings.json".text = builtins.toJSON {
    audioSharingEnabled = true;
    preferredCaptureDevice = "pipewire";
    minimizeToTray = true;
    discordBranch = "stable";
  };
}