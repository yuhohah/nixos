{ config, lib, ... }:

{
  options.my.system.networking.enable = lib.mkEnableOption "Networking Config";

  config = lib.mkIf config.my.system.networking.enable {
    networking = {
      nameservers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
      networkmanager.enable = true;  # gerenciador de rede
      firewall = {
        enable = true;
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
        trustedInterfaces = [ "waydroid0" ];
      };
    };
  };
}
