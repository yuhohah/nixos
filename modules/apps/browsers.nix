{ pkgs, ... }:
{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    chromium
    brave
    tor-browser
  ];

  nixpkgs.config = {
    chromium = {
      enableWideVine = true;  # Habilita suporte ao DRM
    };
  };
}

