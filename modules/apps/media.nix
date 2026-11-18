{ lib, pkgs, ... }:

let
  vesktopWaylandVulkan = pkgs.symlinkJoin {
    name = "vesktop-wayland-vulkan-${pkgs.vesktop.version}";
    paths = [ pkgs.vesktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/vesktop" \
        --add-flags ${lib.escapeShellArg (lib.concatStringsSep " " [
          "--ozone-platform-hint=auto"
          "--enable-wayland-ime=true"
          "--use-gl=angle"
          "--use-angle=vulkan"
          "--disable-vulkan-surface"
          "--enable-webrtc-pipewire-capturer"
          "--enable-features=Vulkan,DefaultANGLEVulkan,VulkanFromANGLE,AcceleratedVideoDecodeLinuxGL,WaylandWindowDecorations,WebRTCPipeWireCapturer"
        ])}
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    vlc
    qbittorrent
    vesktopWaylandVulkan
    obs-studio
    gimp
    spotify
  ];

  home-manager.users.luan.imports = [
    ../../home/vesktop/config.nix
  ];
}
