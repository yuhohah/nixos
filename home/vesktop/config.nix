{ ... }:

{ 
  home.file.".config/vesktop-flags.conf".text = ''
    --ozone-platform-hint=auto
    --enable-wayland-ime=true
    --use-gl=angle
    --use-angle=vulkan
    --disable-vulkan-surface
    --enable-webrtc-pipewire-capturer
    --enable-features=Vulkan,DefaultANGLEVulkan,VulkanFromANGLE,AcceleratedVideoDecodeLinuxGL,WaylandWindowDecorations,WebRTCPipeWireCapturer
  '';

  home.file.".config/vesktop/settings.json".text = builtins.toJSON {
    audioSharingEnabled = true;
    preferredCaptureDevice = "pipewire";
    minimizeToTray = true;
    discordBranch = "stable";
  };
}