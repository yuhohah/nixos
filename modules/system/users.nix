{ pkgs, ... }:

{
  users.groups.luan = {};  # cria o grupo "luan"

  users.users.luan = {
    isNormalUser = true;
    description = "Luan";
    group = "luan";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    home = "/home/luan";
    packages = with pkgs; [ tree ];
  };
}

