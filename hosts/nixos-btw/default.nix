{ pkgs, ... }:

{
  networking.hostName = "nixos-btw";
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
  my.system.apparmor.enable = true;

  # Oculta as saídas ALC887 e mantém apenas o microfone Razer.
  services.pipewire.wireplumber.extraConfig."51-audio-devices" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "~alsa_output[.]pci-0000_0a_00[.]3[.].*"; }
          {
            "media.class" = "Audio/Source";
            "node.name" = "!~alsa_input[.]usb-Razer_Razer_USB_Sound_Card_.*";
          }
        ];
        actions.update-props."node.disabled" = true;
      }
    ];
  };
  
  # Role de jogos e usuário
  my.roles.gaming.enable = true;

  # Stack de AI e segredos (apenas no desktop workstation/servidor)
  home-manager.users.luan.imports = [
    ../../home/t3code
    ../../home/secrets
  ];

  # Kernel mais recente
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Disco secundário específico da máquina
  fileSystems."/mnt/disk" = {
    device = "/dev/disk/by-uuid/CA28A08128A06E5F";
    fsType = "ntfs3";
    options = [ "rw" "uid=1000" "gid=100" "dmask=027" "fmask=137" "noatime" "nofail" ];
  };

  fileSystems."/mnt/Extra" = {
    device = "/dev/disk/by-uuid/67dbb860-fcae-41ba-a7ce-29e2543921f7";
    fsType = "ext4";
    options = [ "defaults" "noatime" ];
  };

  # SSH para acesso remoto e túnel T3 Code
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
              --bg \
              --https=443 \
              --yes \
              http://127.0.0.1:3773
        fi
      '';
    };
  };
}
