{ config, lib, ... }:

{
  options.my.system.apparmor.enable = lib.mkEnableOption "AppArmor Mandatory Access Control";

  config = lib.mkIf config.my.system.apparmor.enable {
    security.apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };
  };
}
