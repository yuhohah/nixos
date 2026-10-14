{ pkgs, ... }:

{
  networking.hostName = "nixos-btw";
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
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
  
  # Role de jogos e usuário
  my.roles.gaming.enable = true;

  # Aplicativos
  my.apps.core.enable = true;
  my.apps.media.enable = true;
  my.apps.dev.enable = true;
  my.apps.browsers.enable = true;
  my.apps.waydroid.enable = false;

  # Kernel mais recente
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Disco secundário específico da máquina
  fileSystems."/mnt/disk" = {
    device = "/dev/disk/by-uuid/CA28A08128A06E5F";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=100" "dmask=000" "fmask=000" "allow_other" ];
  };

  # SSH para acesso remoto e túnel T3 Code + OmniRoute
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # Libera a porta SSH no firewall
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Permite login sem senha a partir do notebook (arrow)
  users.users.luan.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWIovLxUNhoNHtYwSVduhurWeQkttct4dOrNALPrhNB luan@arrow"
  ];

  # Publica o T3 Code via HTTPS seguro na rede privada Tailscale (acesso direto pelo navegador de qualquer aparelho)
  systemd.services.tailscale-service-t3 = {
    description = "Publicar T3 Code via Tailscale Serve (HTTPS :443)";
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "tailscale-serve-t3" ''
        if ${pkgs.tailscale}/bin/tailscale status >/dev/null 2>&1; then
          ${pkgs.util-linux}/bin/flock /run/tailscale-services.lock \
            ${pkgs.tailscale}/bin/tailscale serve \
              --https=443 \
              --yes \
              http://127.0.0.1:3773
        fi
      '';
    };
  };
}
