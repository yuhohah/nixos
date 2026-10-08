{ config, lib, pkgs, ... }:

let
  terminalSaver = pkgs.writeShellScriptBin "terminal-saver" ''
    LOGO_FILE="$HOME/.config/fastfetch/logo.txt"
    if [ ! -f "$LOGO_FILE" ]; then
      LOGO_FILE="${../fastfetch/logo.txt}"
    fi

    EFFECTS=("beams" "spotlights" "rain" "print" "burn" "colorshift" "laseretch" "unstable")

    while true; do
      EFFECT=''${EFFECTS[$RANDOM % ''${#EFFECTS[@]}]}
      clear
      cat "$LOGO_FILE" | ${pkgs.python3Packages.terminaltexteffects}/bin/tte \
        --anchor-canvas c \
        --anchor-text c \
        "$EFFECT" \
        --final-gradient-stops a6e3a1 cdd6f4 \
        --final-gradient-steps 12
      sleep 1
    done
  '';

  runScreensaver = pkgs.writeShellScriptBin "run-screensaver" ''
    ${pkgs.alacritty}/bin/alacritty \
      --config-file "$HOME/.config/alacritty/screensaver.toml" \
      -e ${terminalSaver}/bin/terminal-saver
  '';
in
{
  home.packages = [ terminalSaver runScreensaver ];

  # Compatibilidade para chamadas via ~/.local/bin/
  home.file.".local/bin/run-screensaver".source = "${runScreensaver}/bin/run-screensaver";

  # Alacritty Configuration for terminal-saver
  home.file.".config/alacritty/screensaver.toml".source = ../alacritty/screensaver.toml;
}
