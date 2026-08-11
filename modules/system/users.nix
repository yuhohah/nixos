{ config, lib, pkgs, ... }:

{
  options.my.system.users.enable = lib.mkEnableOption "Users Config";

  config = lib.mkIf config.my.system.users.enable {
    users.groups.luan = {};

    users.users.luan = {
      isNormalUser = true;
      description = "Luan";
      group = "luan";
      extraGroups = [ "wheel" "networkmanager" "audio" "video" "storage" "usb" "docker" ];
      home = "/home/luan";
      homeMode = "700";
      packages = with pkgs; [ tree ];
    };
  };
}
