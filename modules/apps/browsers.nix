{ pkgs, ... }:
{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    chromium
    vivaldi 
    #tor-browser
  ];

  nixpkgs.config = {
    chromium = {
      enableWideVine = true;  # Habilita suporte ao DRM
    };
  };

  environment.variables.CHROME_FLAGS = "--password-store=basic";
}

