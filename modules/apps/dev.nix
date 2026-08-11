{ config, lib, pkgs, ... }:
{
  options.my.apps.dev.enable = lib.mkEnableOption "Dev Apps Config";

  config = lib.mkIf config.my.apps.dev.enable {
    environment.systemPackages = with pkgs; [
      vscode 
      obsidian 
      antigravity-ide 
      docker-compose
      #godot 
      #lua 
      #love 
      #android-studio 
      #lmstudio
    ];

    virtualisation.docker.enable = true;
  };
}
