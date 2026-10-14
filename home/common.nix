{ pkgs, ... }:

{
  home.username = "luan";
  home.homeDirectory = "/home/luan";

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

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

    # AI & Secrets
    ./omniroute
    ./t3code
    ./secrets
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

    shellAliases = {
      ai-tunnel = "ssh -N nixos-ai-tunnel";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" ];
      theme = "robbyrussell";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraConfig = ''
      Host nixos-btw
        HostName nixos-btw.local
        User luan
        IdentityFile ~/.ssh/id_ed25519
        ServerAliveInterval 30
        ServerAliveCountMax 3

      Host nixos-ai-tunnel
        HostName nixos-btw.local
        User luan
        IdentityFile ~/.ssh/id_ed25519
        LocalForward 3773 localhost:3773
        LocalForward 20128 localhost:20128
        ServerAliveInterval 30
        ServerAliveCountMax 3
    '';
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

  home.file."Templates/Novo Documento.txt".text = "";

  # Variáveis de ambiente para Wayland
  home.sessionVariables = {
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Classic";  # Mude se escolher outro tema
  };

}
