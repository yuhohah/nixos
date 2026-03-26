{ pkgs, ... }:

{
  users.groups.luan = {};  # cria o grupo "luan"

  users.users.luan = {
    isNormalUser = true;
    description = "Luan";
    group = "luan";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "storage" "usb" ];
    home = "/home/luan";
    homeMode = "700"; # Impede que outros usuários (como o convidado) acessem sua pasta
    packages = with pkgs; [ tree ];
  };

  # Guest User (Convidado)
  #users.groups.convidado = {};

  #users.users.convidado = {
  #  isNormalUser = true;
  #  description = "Convidado";
  #  group = "convidado";
  #  # Apenas grupos básicos, sem acesso root (wheel) ou dispositivos críticos
  #  extraGroups = [ "networkmanager" "audio" "video" ];
  #  home = "/home/convidado";
  #};
}
