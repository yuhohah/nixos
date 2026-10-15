{ pkgs, ... }:

{
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
    exfatprogs
    
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
}
