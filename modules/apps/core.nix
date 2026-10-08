{ config, lib, pkgs, ... }:
{
  options.my.apps.core.enable = lib.mkEnableOption "Core Apps Config";

  config = lib.mkIf config.my.apps.core.enable {
    environment.systemPackages = with pkgs; [
      # Principais Dependências do Sistema
      wget
      tree
      neovim
      awww 
      nautilus
      pavucontrol
      home-manager
      btop
      bash
      hypridle
      terminaltexteffects
      ntfs3g
      exfat
      
      # Dependências do Screenshot
      grim
      slurp
      wl-clipboard
      wayfreeze
      satty
      jq
      libnotify
      
      libratbag
      piper 
      aisleriot
    ];

    security.pam.services.hyprlock = {};
  };
}
