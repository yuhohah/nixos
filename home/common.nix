{ config, pkgs, unstable, hostName, ... }:

{
  home.username = "luan";
  home.homeDirectory = "/home/luan";
  home.packages = with pkgs; [ brightnessctl networkmanagerapplet ];

  wayland.windowManager.hyprland = {
  enable = true;
  systemd.enable = true;  # opcional, mas recomendado
  configType = "hyprlang";
  # xwayland.enable = true;  # se precisar de X11 apps
  };

  imports = [
    ./theme.nix

    #scripts
    ../scripts/screenshot.nix
    ../scripts/screensaver.nix
  ];


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
      user.name = "yuhohah";  # ← Mude aqui
      user.email = "luandepaulamota@hotmail.com";
    };
   
  };

  # ========================================
  # CONFIGURAÇÃO DO CURSOR
  # ========================================
  
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;

    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    
  };

  # Variáveis de ambiente para Wayland
  home.sessionVariables = {
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Classic";  # Mude se escolher outro tema
  };

  # Script de alerta de bateria
  home.file.".local/bin/battery-alert" = {
    source = ./scripts/battery-alert.sh;
    executable = true;
  };

  # 3. Adicionar o diretório de scripts ao PATH
  home.sessionPath = [ "$HOME/.local/bin" ];



}

