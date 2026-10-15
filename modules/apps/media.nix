{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vlc 
    qbittorrent 
    vesktop 
    obs-studio 
    gimp 
    spotify
  ];

  home-manager.users.luan.imports = [
    ../../home/vesktop/config.nix
  ];
}
