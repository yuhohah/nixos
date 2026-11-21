{ pkgs, ... }:

let
  screensaverConfig = ../alacritty/screensaver.toml;

  terminalSaver = pkgs.writeShellScriptBin "terminal-saver" ''
    LOGO_FILE="$HOME/.config/fastfetch/logo.txt"
    if [ ! -f "$LOGO_FILE" ]; then
      LOGO_FILE="${../fastfetch/logo.txt}"
    fi

    EFFECTS=("beams" "spotlights" "rain" "print" "burn" "colorshift" "laseretch" "unstable")

    printf '\033[?25l'
    trap 'printf "\033[?25h"; exit 0' EXIT INT TERM HUP

    while true; do
      EFFECT=''${EFFECTS[$RANDOM % ''${#EFFECTS[@]}]}
      printf '\033[2J\033[H'
      ${pkgs.python3Packages.terminaltexteffects}/bin/tte \
        --anchor-canvas c \
        --anchor-text c \
        "$EFFECT" \
        --final-gradient-stops a6e3a1 cdd6f4 \
        --final-gradient-steps 12 < "$LOGO_FILE"
      sleep 1
    done
  '';

  stopScreensaver = pkgs.writeShellScriptBin "stop-screensaver" ''
    ${pkgs.procps}/bin/pkill -f '[a]lacritty --class screensaver' 2>/dev/null || true
    ${pkgs.procps}/bin/pkill -f '[t]erminal-saver' 2>/dev/null || true
    if command -v hyprctl >/dev/null 2>&1; then
      hyprctl keyword cursor:inactive_timeout 0 >/dev/null 2>&1 || true
    fi
  '';

  runScreensaver = pkgs.writeShellScriptBin "run-screensaver" ''
    set -euo pipefail

    # Nunca abrir screensaver enquanto a sessão estiver bloqueada
    if ${pkgs.procps}/bin/pgrep -x hyprlock >/dev/null 2>&1; then
      exit 0
    fi

    # Evita instâncias duplicadas do screensaver
    if ${pkgs.procps}/bin/pgrep -f '[a]lacritty --class screensaver' >/dev/null 2>&1; then
      exit 0
    fi

    CONFIG_FILE="$HOME/.config/alacritty/screensaver.toml"
    if [ ! -f "$CONFIG_FILE" ]; then
      CONFIG_FILE="${screensaverConfig}"
    fi

    if command -v hyprctl >/dev/null 2>&1; then
      hyprctl keyword cursor:inactive_timeout 0.1 >/dev/null 2>&1 || true

      mapfile -t WORKSPACES < <(
        hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '
          [ .[] | select(.disabled == false) |
            if (.specialWorkspace.name // "") != "" then
              .specialWorkspace.name
            else
              (.activeWorkspace.id | tostring)
            end
          ] | unique | .[]
        '
      )

      if [ "''${#WORKSPACES[@]}" -gt 0 ]; then
        for ws in "''${WORKSPACES[@]}"; do
          hyprctl dispatch exec "[workspace ''${ws} silent] ${pkgs.alacritty}/bin/alacritty --class screensaver --title screensaver --config-file \"$CONFIG_FILE\" -e ${terminalSaver}/bin/terminal-saver" >/dev/null 2>&1 || true
        done
        exit 0
      fi
    fi

    exec ${pkgs.alacritty}/bin/alacritty \
      --class screensaver \
      --title screensaver \
      --config-file "$CONFIG_FILE" \
      -e ${terminalSaver}/bin/terminal-saver
  '';
in
{
  home.packages = [ terminalSaver runScreensaver stopScreensaver ];

  # Compatibilidade para chamadas via ~/.local/bin/
  home.file.".local/bin/run-screensaver".source = "${runScreensaver}/bin/run-screensaver";
  home.file.".local/bin/stop-screensaver".source = "${stopScreensaver}/bin/stop-screensaver";

  # Alacritty Configuration for terminal-saver
  home.file.".config/alacritty/screensaver.toml".source = screensaverConfig;
}
