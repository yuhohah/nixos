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
    ./theme.nix

    ./hyprland/appearance.nix
    ./hyprland/autostart.nix
    ./hyprland/keybinds.nix
    ./hyprland/monitors.nix
    ./hyprland/hypridle.nix
    ./waybar/config.nix
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
    text = ''
      #!/usr/bin/env bash
      LOGO_FILE="$HOME/.config/fastfetch/logo.txt"
      EFFECTS=("beams" "decrypt" "rain" "middleout" "spotlights")
      
      while true; do
        EFFECT=''${EFFECTS[$RANDOM % ''${#EFFECTS}]}
        clear
        # Usa a cor verde (a6e3a1) e texto (cdd6f4) do seu tema
        cat "$LOGO_FILE" | terminaltexteffects --effect "$EFFECT" \
            --final-gradient-stops a6e3a1 cdd6f4 \
            --final-gradient-steps 12
        sleep 1
      done
    '';
    executable = true;
  };

  # 2. A Configuração Específica do Alacritty para Screensaver
  # Baseado no seu arquivo screensaver.nix
  home.file.".config/alacritty/screensaver.toml".text = ''
    [colors.primary]
    background = "#000000"
    foreground = "#a6e3a1"

    [window]
    opacity = 1.0
    padding = { x = 0, y = 0 }
    decorations = "None"
    startup_mode = "Fullscreen"
    dynamic_title = false

    [font]
    size = 18.0
    normal = { family = "JetBrainsMono Nerd Font Mono" }

    [cursor]
    style = { shape = "Hidden" }
  '';

  # 3. Um script lançador para abrir o Alacritty com essa config
  home.file.".local/bin/run-screensaver" = {
    text = ''
      #!/usr/bin/env bash
      # Lança o Alacritty apontando para o config de screensaver e rodando o script de animação
      alacritty --config-file ~/.config/alacritty/screensaver.toml -e ~/.local/bin/term-saver
    '';
    executable = true;
  };

}

