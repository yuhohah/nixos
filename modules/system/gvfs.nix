{ config, pkgs, ... }:

{
  # Enable GVfs for Nautilus' admin protocol and other features
  services.gvfs.enable = true;

  # Enable Gnome Keyring for storing passwords
  services.gnome.gnome-keyring.enable = true;

  # Enable Polkit for authentication
  security.polkit.enable = true;

  # Enable dconf for Nautilus settings
  programs.dconf.enable = true;
  
  # Add some useful nautilus extensions and polkit agent
  environment.systemPackages = with pkgs; [
    nautilus-python # Required for many nautilus extensions
    polkit_gnome    # Authentication agent for Polkit
  ];

  # Systemd service for the polkit agent (if not started manually)
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
