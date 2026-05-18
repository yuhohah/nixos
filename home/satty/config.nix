{ config, pkgs, ... }:

{
  home.file.".config/satty/config.toml".text = ''
    [general]
    save-after-copy = true
    early-exit = true
    output-filename = "${config.home.homeDirectory}/Pictures/Screenshots/screenshot-%Y-%m-%d_%H-%M-%S.png"
    copy-command = "wl-copy"
    
    primary-highlighter = "block"
    
    [font]
    family = "JetBrainsMono Nerd Font Mono"
  '';
}