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
    grim
    slurp
    wl-clipboard
    wayfreeze
    satty
    jq
    libnotify
   
    fuzzel
   
  ];
}

