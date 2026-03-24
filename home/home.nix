{ config, pkgs, unstable, ... }:

{
  home.username = "luan";
  home.homeDirectory = "/home/luan";
  home.packages = with pkgs; [ brightnessctl networkmanagerapplet ];

  wayland.windowManager.hyprland = {
  enable = true;
  systemd.enable = true;  # opcional, mas recomendado
  # xwayland.enable = true;  # se precisar de X11 apps
  };

  imports = [
    ./theme.nix

    ./hyprland/appearance.nix
    ./hyprland/autostart.nix
    ./hyprland/keybinds.nix
    ./hyprland/monitors.nix
    #./hyprland/windowrules.nix
    ./hyprland/hypridle.nix
    ./hyprland/hyprlock.nix
    ./waybar/notebook.nix
    ./alacritty/default.nix

    ./vesktop/config.nix    
    ./satty/config.nix
    ./fastfetch/default.nix
    ./mako/default.nix
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

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
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

  # 1. O Script de Animação
  home.file.".local/bin/term-saver" = {
    source = ./scripts/term-saver.sh;
    executable = true;
  };

  # 2. A Configuração Específica do Alacritty para Screensaver
  # Baseado no seu arquivo screensaver.nix
  home.file.".config/alacritty/screensaver.toml".source = ./alacritty/screensaver.toml;

  # 3. Um script lançador para abrir o Alacritty com essa config
  home.file.".local/bin/run-screensaver" = {
    source = ./scripts/run-screensaver.sh;
    executable = true;
  };

}

