{ config, lib, ... }:

{
  options.my.system.networking = {
    enable = lib.mkEnableOption "Networking Config";
    mdns.enable = lib.mkEnableOption "mDNS (.local) discovery via Avahi (opens UDP 5353)";
  };

  config = lib.mkIf config.my.system.networking.enable {
    networking = {
      nameservers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
      networkmanager.enable = true;  # gerenciador de rede
      firewall = {
        enable = true;
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
        trustedInterfaces = [ "tailscale0" ];
      };
    };

    # Resolução mDNS (.local) opcional — desativada por padrão para não expor UDP 5353 em redes públicas
    services.avahi = lib.mkIf config.my.system.networking.mdns.enable {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Tailscale VPN mesh para acesso remoto seguro de qualquer rede pública/externa
    services.tailscale = {
      enable = true;
      extraSetFlags = [ "--operator=luan" ];
      openFirewall = true;
      useRoutingFeatures = "both";
    };
  };
}
