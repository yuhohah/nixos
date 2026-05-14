{ config, lib, pkgs, ... }:

{
  options.my.system.networking.enable = lib.mkEnableOption "Networking Config";

  config = lib.mkIf config.my.system.networking.enable {
    networking = {
      nameservers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
      networkmanager.enable = true;  # gerenciador de rede
      firewall = {
        enable = true;
        allowedTCPPorts = [ 22 80 443 ]; # exemplo
        allowedUDPPorts = [ ];
        trustedInterfaces = [ "waydroid0" ];
      };
    };

    time.timeZone = "America/Sao_Paulo";

    i18n = {
      defaultLocale = "pt_BR.UTF-8";
      extraLocaleSettings = {
        LC_TIME = "pt_BR.UTF-8";
        LC_MONETARY = "pt_BR.UTF-8";
        LC_NUMERIC = "pt_BR.UTF-8";
        LC_MEASUREMENT = "pt_BR.UTF-8";
      };
    };
  };
}
