{ config, pkgs, ... }:

{
  xdg.configFile."vicinae/settings.json".force = true;
  xdg.configFile."vicinae/settings.json".text = builtins.toJSON {
    theme = {
      dark = {
        name = "nixos-custom";
        icon_theme = "auto";
      };
      light = {
        name = "nixos-custom";
        icon_theme = "auto";
      };
    };
    launcher_window = {
      client_side_decorations = {
        enabled = true;
        rounding = 12;
        border_width = 2;
      };
    };
  };

  xdg.configFile."vicinae/themes/nixos-custom.toml".text = ''
    [meta]
    version = 1
    name = "nixos-custom"
    description = "Custom theme for NixOS based on Catppuccin Macchiato/Mocha"
    variant = "dark"

    [colors.core]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    secondary_background = "#313244"
    border = "#cba6f7"
    accent = "#cba6f7"

    [colors.accents]
    blue = "#89b4fa"
    green = "#a6e3a1"
    magenta = "#f5c2e7"
    orange = "#fab387"
    purple = "#cba6f7"
    red = "#f38ba8"
    yellow = "#f9e2af"
    cyan = "#94e2d5"
  '';
}
