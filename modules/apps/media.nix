{ config, lib, pkgs, ... }:
{
  options.my.apps.media.enable = lib.mkEnableOption "Media Apps Config";

  config = lib.mkIf config.my.apps.media.enable {
    environment.systemPackages = with pkgs; [
      vlc 
      qbittorrent 
      vesktop 
      obs-studio 
      gimp 
      spotify
    ];
  };
}
