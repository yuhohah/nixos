{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vscode
    obsidian
    code-cursor
  ];
}

