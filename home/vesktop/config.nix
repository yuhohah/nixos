{ ... }:

{ 
  home.file.".config/vesktop-flags.conf".text = ''
    --enable-features=WaylandWindowDecorations
    --ozone-platform-hint=auto
    --enable-webrtc-pipewire-capturer
    --enable-features=WebRTCPipeWireCapturer
  '';

  home.file.".config/vesktop/settings.json".text = builtins.toJSON {
    audioSharingEnabled = true;
    preferredCaptureDevice = "pipewire";
    minimizeToTray = true;
    discordBranch = "stable";
  };
}