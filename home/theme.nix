{ pkgs, ... }:

{
  # ========================================
  # TEMA GTK (Gnome/Apps padrão)
  # ========================================
  gtk = {
    enable = true;
    
    # Define o tema escuro
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    # Define o tema de ícones (opcional, mas recomendado para consistência)
    iconTheme = {
      name = "Adwaita"; # ou Papirus-Dark, etc.
      package = pkgs.adwaita-icon-theme;
    };

    # Força a preferência por tema escuro em arquivos de configuração
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

  # ========================================
  # CONFIGURAÇÃO DCONF (Essencial para GTK4/Libadwaita)
  # ========================================
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # ========================================
  # TEMA QT (KDE/Apps Qt)
  # ========================================
  qt = {
    enable = true;
    platformTheme.name = "gtk"; # Faz o Qt seguir o tema do GTK
    style.name = "adwaita-dark";
  };
}