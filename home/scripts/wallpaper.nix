{ config, lib, pkgs, ... }:

let
  cfg = config.wallpaper;

  wallpaperScript = pkgs.writeShellScriptBin "wallpaper" ''
    WALLPAPER_DIR="${cfg.dir}"

    if [ -n "$1" ]; then
      ${pkgs.awww}/bin/awww img "$1" \
        --transition-type wipe \
        --transition-duration 2
      exit 0
    fi

    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | shuf -n 1)

    if [ -n "$WALLPAPER" ]; then
      ${pkgs.awww}/bin/awww img "$WALLPAPER" \
        --transition-type wipe \
        --transition-duration 2
      echo "Wallpaper changed to: $WALLPAPER"
    else
      echo "No wallpaper found in $WALLPAPER_DIR"
    fi
  '';
in
{
  options.wallpaper = {
    dir = lib.mkOption {
      type = lib.types.path;
      description = "Wallpapers path, relative to configuration.nix.";
      example = lib.literalExpression "./wallpapers";
    };
  };

  config = {
    home.packages = [ wallpaperScript ];

    systemd.user.services.wallpaper = {
      Unit = {
        Description = "Random wallpaper on login";
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${wallpaperScript}/bin/wallpaper";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
