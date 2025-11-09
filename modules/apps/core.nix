{ pkgs, unstable, ... }:
{
  environment.systemPackages = with pkgs; [
    #Principais Dependencias do Sistema
    wget
    tree
    neovim
    alacritty
    waybar
    swww 
    nautilus
    pavucontrol
    home-manager
    numlockx
    unstable.vicinae
    btop
    bash
    hypridle
    hyprlock

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
    
    
    #Lixo legal
    fastfetch

    fuzzel
   
  ];
}

