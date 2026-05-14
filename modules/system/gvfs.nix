{ config, lib, pkgs, ... }:

{
  options.my.system.gvfs.enable = lib.mkEnableOption "GVFS Config";

  config = lib.mkIf config.my.system.gvfs.enable {
    services.gvfs.enable = true;
    services.gnome.gnome-keyring.enable = false;
    security.polkit.enable = true;
    programs.dconf.enable = true;
    
    environment.systemPackages = with pkgs; [
      nautilus-python
      polkit_gnome
    ];

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
  };
}
