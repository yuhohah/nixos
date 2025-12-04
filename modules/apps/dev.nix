{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vscode
    obsidian
    lmstudio
    antigravity
  ];
}

