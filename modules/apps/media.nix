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

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.ubuntu
      font-awesome
      material-design-icons
      noto-fonts-color-emoji
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font Mono" "Noto Color Emoji" ];
        sansSerif = [ "Ubuntu Nerd Font" "Noto Color Emoji" ];
        serif = [ "Noto Serif" "Noto Color Emoji" ];
      };
    };
  };
}
