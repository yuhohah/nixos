{ pkgs, unstable, ... }:
{
  environment.systemPackages = with pkgs; [
    wget
    tree
    neovim
    alacritty
    kitty
    waybar
    wofi
    swww 
    nautilus
    steam
    pavucontrol
    home-manager
    fuzzel
    numlockx
    unstable.vicinae


    bash
    grim
    slurp
    wl-clipboard
    wayfreeze
    satty
    jq
    libnotify
  ];
}

