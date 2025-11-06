{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vlc
    qbittorrent
    vesktop
    obs-studio

  ];

  fonts.packages = with pkgs; [
    # Fontes de ícones
    nerd-fonts.jetbrains-mono
    nerd-fonts.ubuntu
    font-awesome
    material-design-icons
    
    # Fontes emojis
    noto-fonts-emoji
    
  
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font Mono" "Noto Color Emoji" ];
      sansSerif = [ "Ubuntu Nerd Font" "Noto Color Emoji" ];
      serif = [ "Noto Serif" "Noto Color Emoji" ];
    };
  };
}

