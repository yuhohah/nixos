{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vscode
    obsidian
    antigravity
    godot
    lua
    love
    android-studio
    lmstudio
  ];
}

