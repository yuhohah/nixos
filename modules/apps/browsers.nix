{ lib, pkgs, ... }:

let
  chromiumWaylandVulkanArgs = lib.concatStringsSep " " [
    "--ozone-platform-hint=auto"
    "--enable-wayland-ime=true"
    "--use-gl=angle"
    "--use-angle=vulkan"
    "--disable-vulkan-surface"
    "--enable-features=Vulkan,DefaultANGLEVulkan,VulkanFromANGLE,AcceleratedVideoDecodeLinuxGL,WaylandWindowDecorations,WebRTCPipeWireCapturer"
  ];
in
{
  programs.firefox.enable = true;

  environment.systemPackages = [
    (pkgs.chromium.override {
      commandLineArgs = chromiumWaylandVulkanArgs;
    })
  ];

  nixpkgs.config.chromium = {
    enableWideVine = true;
  };
}
