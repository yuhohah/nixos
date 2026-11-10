{ pkgs, ... }:

{
  nixpkgs.overlays = [ (import ../../overlays/ai-tools.nix) ];

  environment.systemPackages = with pkgs; [
    vscode 
    obsidian 
    antigravity-ide 
    codex
    opencode
  ];

  virtualisation.docker.enable = true;
  programs.nix-ld.enable = true;
  programs.wireshark.enable = true;
}
