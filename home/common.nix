{ pkgs, lib, config, hostName ? "nixos-btw", ... }:

{
  home.username = "luan";
  home.homeDirectory = "/home/luan";

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  imports = [
    ./theme.nix

    #scripts
    ./scripts/screenshot.nix
    ./scripts/screensaver.nix
    ./scripts/wallpaper.nix
  ];

  wallpaper.dir = ../images/wallpaper;

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = true;
    videos = "$HOME/Videos";
    desktop = config.home.homeDirectory;
    music = config.home.homeDirectory;
    publicShare = config.home.homeDirectory;
    pictures = "$HOME/Pictures";
    download = "$HOME/Downloads";
    documents = "$HOME/Documents";
    templates = "$HOME/Templates";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      size = 10000;
      save = 10000;
    };
    
    # Configuração do .zshrc
    initContent = ''
      if [[ -o interactive && "''${TERM:-}" != "dumb" ]]; then
        fastfetch
      fi
    '';

    shellAliases = {
      ai-tunnel = "ssh -N nixos-ai-tunnel";
      ai-tunnel-remote = "ssh -N nixos-ai-tunnel-ts";
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
    settings = {
      "*" = {};

      "nixos-btw" = {
        HostName = "nixos-btw.local";
        User = "luan";
        IdentityFile = "~/.ssh/id_ed25519";
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
      };

      "nixos-ai-tunnel" = {
        HostName = "nixos-btw.local";
        User = "luan";
        IdentityFile = "~/.ssh/id_ed25519";
        LocalForward = [
          "3773 localhost:3773"
        ];
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
      };

      # Conexão remota via Tailscale (para uso em redes externas / públicas)
      "nixos-ai-tunnel-ts" = {
        HostName = "nixos-btw";
        User = "luan";
        IdentityFile = "~/.ssh/id_ed25519";
        LocalForward = [
          "3773 localhost:3773"
        ];
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
      };
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
