{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos-btw";        # nome do host
    networkmanager.enable = true;  # gerenciador de rede
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ]; # exemplo
      allowedUDPPorts = [ ];
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

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ]; 
    allowedUDPPorts = [ ];
    # Adicione esta linha para permitir a internet no Waydroid
    trustedInterfaces = [ "waydroid0" ];
  };

  # Configurações de proxy (opcional)
  # networking.proxy.default = "http://user:pass@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost";
}

