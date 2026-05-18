{ pkgs, ... }:

{
  gtk = {
    enable = true;
    
    # Define o tema escuro
    colorScheme = "dark";

    # Icon Theme
    iconTheme = {
      name = "Adwaita"; 
      package = pkgs.adwaita-icon-theme;
    };

    # Try dark mode
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };
}