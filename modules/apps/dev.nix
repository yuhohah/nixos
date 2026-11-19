{ pkgs, ... }:

{
  nixpkgs.overlays = [ (import ../../overlays/ai-tools.nix) ];

  environment.systemPackages = with pkgs; [
    vscode 
    obsidian 
    antigravity-ide 
    codex
    opencode
    android-studio
    notepad-next
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
  programs.nix-ld.enable = true;
  programs.wireshark.enable = true;
}
