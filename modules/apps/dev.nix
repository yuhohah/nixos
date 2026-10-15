{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vscode 
    obsidian 
    antigravity-ide 
  ];

  virtualisation.docker.enable = true;
  programs.nix-ld.enable = true;
  programs.wireshark.enable = true;
}
