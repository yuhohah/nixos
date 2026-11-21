{ pkgs, ... }:

{
  networking.hostName = "nixos-btw";
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

  # Stack de AI, segredos e layout desktop
  home-manager.users.luan = {
    imports = [
      ../../home/t3code
      ../../home/secrets
    ];

    my.quickshell.configFile = ../../home/quickshell/hosts/nixos-btw/shell.json;

    my.hyprland = {
      keyboard = {
        layout = "us";
        variant = "intl";
      };
      monitors = [
        { output = "HDMI-A-1"; mode = "1920x1080@144"; position = "0x0"; scale = "1"; }
        { output = "HDMI-A-2"; mode = "1920x1080@74.973"; position = "1920x0"; scale = "1"; }
      ];
      workspaces = [
        { workspace = "1"; monitor = "HDMI-A-1"; }
        { workspace = "2"; monitor = "HDMI-A-2"; }
        { workspace = "3"; monitor = "HDMI-A-1"; }
        { workspace = "4"; monitor = "HDMI-A-2"; }
      ];
    };
  };

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

  # SSH restrito à interface tailscale0 e autenticação somente por chave
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "luan" ];
      ClientAliveInterval = 30;
      ClientAliveCountMax = 3;
    };
  };

  # Mosh para sessões móveis resilientes (Wi-Fi <-> 4G/5G), restrito à interface tailscale0
  programs.mosh = {
    enable = true;
    openFirewall = false;
  };

  # Multiplexador de terminal para manter sessões ativas ao acessar pelo celular
  programs.tmux = {
    enable = true;
    clock24 = true;
    historyLimit = 10000;
    extraConfig = ''
      set -g mouse on
    '';
  };

  # Chaves SSH autorizadas (notebook arrow; adicione aqui a chave pública Ed25519 do celular)
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
