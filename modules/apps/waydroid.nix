{ pkgs, ... }:

{
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
}
