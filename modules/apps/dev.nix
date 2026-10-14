{ config, lib, pkgs, ... }:
{
  options.my.apps.dev.enable = lib.mkEnableOption "Dev Apps Config";

  config = lib.mkIf config.my.apps.dev.enable {
    environment.systemPackages = with pkgs; [
      vscode 
      obsidian 
      antigravity-ide 
      #android-studio 
      #lmstudio
      (t3code.override { enableOpencode = true; })
    ];

    virtualisation.docker.enable = true;
    programs.nix-ld.enable = true;
    programs.wireshark.enable = true;
  };
}
