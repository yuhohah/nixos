{ pkgs, ... }:
{
  virtualisation.waydroid.enable = true;

  # Dependencies for waydroid-extras script (GAPPS/libhoudini)
  environment.systemPackages = with pkgs; [
    git
    lzip
    python3
    curl
    jq
  ];

  # Firewall rules for Waydroid (optional but often needed)
  networking.firewall.trustedInterfaces = [ "waydroid0" ];

  
}