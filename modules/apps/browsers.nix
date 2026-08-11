{ config, lib, pkgs, ... }:
{
  options.my.apps.browsers.enable = lib.mkEnableOption "Browsers Config";

  config = lib.mkIf config.my.apps.browsers.enable {
    programs.firefox.enable = true;

    environment.systemPackages = with pkgs; [
      chromium 
    ];

    nixpkgs.config = {
      chromium = {
        enableWideVine = true;
      };
    };

    environment.variables.CHROME_FLAGS = "--password-store=basic";
  };
}
