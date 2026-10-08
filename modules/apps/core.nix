{ config, lib, pkgs, ... }:
{
  options.my.apps.core.enable = lib.mkEnableOption "Core Apps Config";

  config = lib.mkIf config.my.apps.core.enable {
    environment.systemPackages = with pkgs; [
      #Principais Dependencias do Sistema
      wget
      tree
      neovim
      alacritty
      awww 
      nautilus
      pavucontrol
      home-manager
      vicinae
      btop
      bash
      hypridle
      hyprlock
      terminaltexteffects
      ntfs3g
      exfat
      
      #Dependencias do Screenshot
      grim
      slurp
      wl-clipboard
      wayfreeze
      satty
      jq
      libnotify
      hyprland

      wireplumber    # gerenciador de sessão do pipewire
      xdg-desktop-portal-hyprland  # portal para screen sharing
      xdg-desktop-portal-gtk       # portal GTK (fallback)
      
      libratbag
      piper 
      aisleriot
      
      #Lixo legal
      fastfetch
    ];

    security.pam.services.hyprlock = {};
  };
}
