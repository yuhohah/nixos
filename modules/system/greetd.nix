{ config, lib, pkgs, ... }: 
{
  options.my.system.greetd.enable = lib.mkEnableOption "Greetd Config";

  config = lib.mkIf config.my.system.greetd.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd '${pkgs.uwsm}/bin/uwsm start -e -D Hyprland hyprland.desktop'";
          user = "greeter";
        };
      };
    };

    environment.sessionVariables = {
      GTK_THEME = "Adwaita-dark";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_STYLE_OVERRIDE = "adwaita-dark";
    };
  };
}
