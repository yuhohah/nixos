{ config, lib, pkgs, ... }:

{
  options.my.apps.waydroid.enable = lib.mkEnableOption "Waydroid Android container support";

  config = lib.mkIf config.my.apps.waydroid.enable {
    virtualisation.waydroid.enable = true;
    virtualisation.waydroid.package = pkgs.waydroid-nftables;

    environment.systemPackages = with pkgs; [
      git
      lzip
      python3
      curl
      jq
    ];

    networking.firewall.trustedInterfaces = [ "waydroid0" ];
  };
}
