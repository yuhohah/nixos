{ config, pkgs, unstable, hostName, ... }:

{
  home.username = "luan";
  home.homeDirectory = "/home/luan";
  home.packages = with pkgs; [ brightnessctl networkmanagerapplet ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;  # opcional, mas recomendado
    configType = "lua";
    # xwayland.enable = true;  # se precisar de X11 apps
  };

  imports = [
    ./theme.nix

    #scripts
    ./scripts/screenshot.nix
    ./scripts/screensaver.nix
    ./scripts/wallpaper.nix
  ];


  wallpaper.dir = ../images/wallpaper;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    # Configuração do .zshrc
    initContent = ''    
        fastfetch
      
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" ];
      theme = "robbyrussell";
    };
  };

  home.stateVersion = "25.05";

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };

  services.activitywatch = {
    enable = true;
    # Isso garante que ele inicie automaticamente na sua sessão
    package = pkgs.activitywatch;
  };

  programs.git = {
    enable = true;
    settings ={
      user.name = "yuhohah";
      user.email = "luandepaulamota@hotmail.com";
    };
   
  };

home.pointerCursor.enable = true;
  home.pointerCursor = {

    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    
  };

  # Variáveis de ambiente para Wayland
  home.sessionVariables = {
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Classic";  # Mude se escolher outro tema
  };
}

