{ config, pkgs, unstable, ... }:

{
  home.username = "luan";
  home.homeDirectory = "/home/luan";

  wayland.windowManager.hyprland = {
  enable = true;
  systemd.enable = true;  # opcional, mas recomendado
  # xwayland.enable = true;  # se precisar de X11 apps
  };

  imports = [
    
    ./hyprland/appearance.nix
    ./hyprland/autostart.nix
    ./hyprland/keybinds.nix
    ./hyprland/monitors.nix
    ./waybar/config.nix
    ./alacritty/default.nix

    ./vesktop/config.nix    
    ./satty/config.nix
    #./modules/apps/vscode.nix
    #./modules/apps/vesktop.nix
    #./modules/apps/kitty.nix

    
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


  programs.git = {
    enable = true;
    userName = "yuhohah";  # ← Mude aqui
    userEmail = "luandepaulamota@hotmail.com";
  };

  # ========================================
  # CONFIGURAÇÃO DO CURSOR
  # ========================================
  
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    
    # Escolha um dos temas abaixo:
    
    # Opção 1: Bibata Modern (popular, moderno)
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    
    # Opção 2: Catppuccin (combina com seu tema)
    # package = pkgs.catppuccin-cursors.mochaDark;
    # name = "catppuccin-mocha-dark-cursors";
    # size = 24;
    
    # Opção 3: Nordzy (elegante)
    # package = pkgs.nordzy-cursor-theme;
    # name = "Nordzy-cursors";
    # size = 24;
    
    # Opção 4: Phinger (minimalista)
    # package = pkgs.phinger-cursors;
    # name = "phinger-cursors-light";
    # size = 24;
  };

  # Variáveis de ambiente para Wayland
  home.sessionVariables = {
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Classic";  # Mude se escolher outro tema
  };

  # ========================================
  # CONFIGURAÇÃO DO SCRIPT DE SCREENSHOT
  # ========================================
  
  # 1. Copiar o script para o home
  home.file.".local/bin/screenshot" = {
    source = ./scripts/screenshot.sh;
    executable = true;
  };

  # Adicione junto com o script de screenshot
  home.file.".local/bin/wallpaper" = {
    source = ./scripts/wallpaper.sh;
    executable = true;
  };

  # 2. Criar diretório de screenshots
  home.file."Pictures/Screenshots/.keep".text = "";

  # 3. Adicionar o diretório de scripts ao PATH
  home.sessionPath = [ "$HOME/.local/bin" ];

  #Notificacao daemon
  services.mako = {
    enable = true;
    settings.default-timeout = 4000;
  };

}

