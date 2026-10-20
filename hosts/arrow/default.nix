{ pkgs, lib, ... }:

{
  networking.hostName = "arrow";
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
    ../../modules/apps/core.nix
    ../../modules/apps/browsers.nix
    ../../modules/apps/dev.nix
    ../../modules/apps/media.nix
  ];

  generationTracker.configDir = "/home/luan/Configuration/nixos";
  
  # Sistema base
  my.system.core.enable = true;
  my.system.networking.enable = true;
  my.system.audio.enable = true;
  my.system.hyprland.enable = true;
  my.system.greetd.enable = true;
  my.system.users.enable = true;
  my.system.gvfs.enable = true;
  
  # Role de hardware e usuário
  my.roles.laptop.enable = true;

  # Túnel SSH e atalhos para conectar ao workstation desktop (nixos-btw: 100.99.213.109)
  home-manager.users.luan = {
    home.packages = [
      (pkgs.writeShellScriptBin "tunnel-btw" ''
        echo "=========================================================="
        echo " Conectando ao túnel SSH com nixos-btw (100.99.213.109)"
        echo "   - T3 Code:   http://localhost:3773"
        echo "   - OmniRoute: http://localhost:20128/dashboard"
        echo "=========================================================="
        echo ""
        if [ "''${1:-}" = "-s" ] || [ "''${1:-}" = "--shell" ]; then
          shift
          exec ssh -v -L 3773:localhost:3773 -L 20128:localhost:20128 luan@100.99.213.109 "$@"
        else
          echo "Pressione Ctrl+C para encerrar o túnel."
          exec ssh -v -N -L 3773:localhost:3773 -L 20128:localhost:20128 luan@100.99.213.109 "$@"
        fi
      '')

      (pkgs.writeShellScriptBin "tunnel-btw-shell" ''
        echo "=========================================================="
        echo " Conectando ao shell remoto com túnel SSH (100.99.213.109)"
        echo "   - T3 Code:   http://localhost:3773"
        echo "   - OmniRoute: http://localhost:20128/dashboard"
        echo "=========================================================="
        echo ""
        exec ssh -v -L 3773:localhost:3773 -L 20128:localhost:20128 luan@100.99.213.109 "$@"
      '')
    ];

    programs.zsh.shellAliases = {
      ai-tunnel = lib.mkForce "tunnel-btw";
      ai-tunnel-remote = lib.mkForce "tunnel-btw";
      tunnel-btw = "tunnel-btw";
      ssh-btw = "ssh -v luan@100.99.213.109";
    };

    programs.ssh.settings = {
      "100.99.213.109" = {
        HostName = "100.99.213.109";
        User = "luan";
        IdentityFile = "~/.ssh/id_ed25519";
        LocalForward = [
          "3773 localhost:3773"
          "20128 localhost:20128"
        ];
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
      };

      "nixos-ai-tunnel-ts" = {
        HostName = lib.mkForce "100.99.213.109";
      };
    };

    xdg.desktopEntries.ai-tunnel = {
      name = "AI SSH Tunnel (nixos-btw)";
      genericName = "SSH Tunnel";
      comment = "Conecta ao túnel SSH do nixos-btw (T3 Code e OmniRoute)";
      exec = "alacritty -e tunnel-btw";
      terminal = false;
      icon = "network-vpn";
      categories = [ "Network" "Development" ];
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;
}
