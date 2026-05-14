{ pkgs, unstable, ... }:
{
  environment.systemPackages = with pkgs; [
    #Principais Dependencias do Sistema
    wget
    tree
    neovim
    alacritty
    waybar
    awww 
    nautilus
    pavucontrol
    home-manager
    unstable.vicinae
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

    #Dependencias do activity watch
    activitywatch
    aw-watcher-window-wayland

    wireplumber    # gerenciador de sessão do pipewire
    xdg-desktop-portal-hyprland  # portal para screen sharing
    xdg-desktop-portal-gtk       # portal GTK (fallback)
    
    libratbag
    piper 
    
    #Lixo legal
    fastfetch

    fuzzel
   
  ];

  # Habilita a autenticação PAM para o hyprlock (necessário para desbloquear a tela)
  security.pam.services.hyprlock = {};
}
