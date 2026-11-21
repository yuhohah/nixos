{ config, lib, pkgs, ... }:

let
  chromiumWaylandVulkanArgs = lib.concatStringsSep " " [
    "--ozone-platform-hint=auto"
    "--enable-wayland-ime=true"
    "--use-gl=angle"
    "--use-angle=vulkan"
    "--disable-vulkan-surface"
    "--disable-gl-extensions=EGL_EXT_image_dma_buf_import,EGL_EXT_image_dma_buf_import_modifiers"
    "--disable-gpu-memory-buffer-compositor-resources"
    "--disable-gpu-memory-buffer-video-frames"
    "--enable-features=Vulkan,DefaultANGLEVulkan,VulkanFromANGLE,WaylandWindowDecorations,WebRTCPipeWireCapturer"
  ];
in
{
  options.my.apps.browsers.enable = lib.mkEnableOption "Web browsers (Firefox and Chromium)";

  config = lib.mkIf config.my.apps.browsers.enable {
    programs.firefox.enable = true;

    environment.systemPackages = [
      (pkgs.chromium.override {
        commandLineArgs = chromiumWaylandVulkanArgs;
      })
    ];

    nixpkgs.config.chromium = {
      enableWideVine = true;
    };
  };
}
