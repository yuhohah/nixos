{ pkgs, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    chromium 
  ];

  nixpkgs.config.chromium = {
    enableWideVine = true;
  };
}
