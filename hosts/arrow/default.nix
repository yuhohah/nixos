{ pkgs, ... }:

{
  networking.hostName = "arrow";
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
  ];

  # Sistema base
  my.system.core.enable = true;
  my.system.networking.enable = true;
  my.system.audio.enable = true;
  my.system.hyprland.enable = true;
  my.system.greetd.enable = true;
  my.system.users.enable = true;
  my.system.gvfs.enable = true;
  my.system.apparmor.enable = true;
  my.system.tracker = {
    enable = true;
    configDir = "/home/luan/Configuration/nixos";
  };

  # Aplicativos
  my.apps.core.enable = true;
  my.apps.browsers.enable = true;
  my.apps.dev.enable = true;
  my.apps.media.enable = true;

  # Role de hardware e usuário
  my.roles.laptop.enable = true;

  # Layout mobile + túnel SSH via Tailscale MagicDNS para o workstation desktop (nixos-btw)
  home-manager.users.luan = {
    my.quickshell.configFile = ../../home/quickshell/hosts/arrow/shell.json;

    my.hyprland = {
      keyboard = {
        layout = "br,es";
        variant = "abnt2,";
      };
      monitors = [
        { output = "eDP-1"; mode = "1920x1080"; position = "0x0"; scale = "1"; }
        { output = "HDMI-A-1"; mode = "1920x1080@144"; position = "1920x0"; scale = "1"; }
      ];
      workspaces = [
        { workspace = "1"; monitor = "eDP-1"; }
      ];
    };

    home.packages = [
      (pkgs.writeShellScriptBin "tunnel-btw" ''
        echo "=========================================================="
        echo " Conectando ao túnel SSH com nixos-btw (Tailscale MagicDNS)"
        echo "   - T3 Code:   http://localhost:3773"
        echo "=========================================================="
        echo ""
        if [ "''${1:-}" = "-s" ] || [ "''${1:-}" = "--shell" ]; then
          shift
          exec ssh -v -L 3773:localhost:3773 nixos-btw "$@"
        else
          echo "Pressione Ctrl+C para encerrar o túnel."
          exec ssh -v -N -L 3773:localhost:3773 nixos-btw "$@"
        fi
      '')

      (pkgs.writeShellScriptBin "tunnel-btw-shell" ''
        echo "=========================================================="
        echo " Conectando ao shell remoto com túnel SSH (nixos-btw)"
        echo "   - T3 Code:   http://localhost:3773"
        echo "=========================================================="
        echo ""
        exec ssh -v -L 3773:localhost:3773 nixos-btw "$@"
      '')
    ];

    programs.zsh.shellAliases = {
      ai-tunnel = "tunnel-btw";
      ai-tunnel-remote = "tunnel-btw";
      tunnel-btw = "tunnel-btw";
      ssh-btw = "ssh -v nixos-btw";
    };

    xdg.desktopEntries.ai-tunnel = {
      name = "AI SSH Tunnel (nixos-btw)";
      genericName = "SSH Tunnel";
      comment = "Conecta ao túnel SSH do nixos-btw (T3 Code)";
      exec = "alacritty -e tunnel-btw";
      terminal = false;
      icon = "network-vpn";
      categories = [ "Network" "Development" ];
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;
}
