{ pkgs, unstable, ... }:
{
  environment.systemPackages = with pkgs; [
    wget
    tree
    neovim
    alacritty

    waybar

    swww 
    nautilus
    steam
    pavucontrol
    home-manager
    fuzzel
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
  ];
}

