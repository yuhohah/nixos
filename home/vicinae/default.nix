{ config, pkgs, ... }:

{
  programs.vicinae = {
    enable = true;
    
    systemd = {
      enable = true;   
      autoStart = true;
    };

    settings = {
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
        rounding = 12;
        opacity = 0.8;
        material = "auto";
        compact_mode.enabled = true;
        client_side_decorations = {
          enabled = true;
          border_width = 1;
          shadow_size = 12;
        };
        layer_shell = {
          enabled = true;
          keyboard_interactivity = "exclusive";
          layer = "top";
        };
      };

      favorites = [ ];
      fallbacks = [ ];

      providers = {
        "calculator".enabled = true;
        "manage-shortcuts".enabled = false;
        "files".enabled = false;
        "raycast-compat".enabled = false;
        "@knoopx/store.vicinae.nix".enabled = false;
      };
    };

    # Vicinae's own HM module writes this to
    # ~/.config/vicinae/themes/nixos-custom.toml for you.
    themes = {
      nixos-custom = {
        meta = {
          name = "nixos-custom";
          version = 1;
          description = "Custom theme for NixOS matching Quickshell Catppuccin Mocha style";
          variant = "dark";
          inherits = "vicinae-dark";
        };

        colors = {
          core = {
            accent = "#cba6f7";
            accent_foreground = "#11111b";
            background = "#1e1e2e";
            foreground = "#cdd6f4";
            secondary_background = "#181825";
            border = "#313244";
          };

          main_window = {
            border = "#313244";
            footer.background = "#181825";
          };

          settings_window.border = "#313244";

          accents = {
            blue = "#89b4fa";
            green = "#a6e3a1";
            magenta = "#f5c2e7";
            orange = "#fab387";
            purple = "#cba6f7";
            red = "#f38ba8";
            yellow = "#f9e2af";
            cyan = "#94e2d5";
          };

          text = {
            default = "#cdd6f4";
            muted = "#6c7086";
            danger = "#f38ba8";
            success = "#a6e3a1";
            placeholder = "#6c7086";
            selection = {
              background = "#cba6f7";
              foreground = "#11111b";
            };
          };

          input = {
            border = "#313244";
            border_focus = "#cba6f7";
            border_error = "#f38ba8";
          };

          button.primary = {
            background = "#313244";
            foreground = "#cdd6f4";
            hover.background = "#45475a";
            focus.outline = "#cba6f7";
          };

          list.item = {
            hover = {
              foreground = "#cdd6f4";
              secondary_foreground = "#a6adc8";
            };
            selection = {
              background = "#313244";
              foreground = "#cdd6f4";
              secondary_background = "#313244";
              secondary_foreground = "#cdd6f4";
            };
          };

          scrollbars.background = "#313244";

          loading = {
            bar = "#cba6f7";
            spinner = "#cba6f7";
          };
        };
      };
    };
  };
}
