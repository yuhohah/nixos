{ config, lib, pkgs, ... }:

let
  desiredSettings = builtins.toJSON {
    audioSharingEnabled = true;
    preferredCaptureDevice = "pipewire";
    minimizeToTray = true;
    discordBranch = "stable";
  };

  vesktopSettingsMerge = pkgs.writeShellScript "vesktop-settings-merge" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath [ pkgs.coreutils pkgs.jq ]}"

    dir="${config.xdg.configHome}/vesktop"
    file="$dir/settings.json"
    mkdir -p "$dir"

    existing="{}"
    if [ -f "$file" ] && jq -e 'type == "object"' "$file" >/dev/null 2>&1; then
      existing=$(cat "$file")
    fi

    tmp=$(mktemp "$dir/.settings.json.XXXXXX")
    trap 'rm -f "$tmp"' EXIT

    printf '%s\n' "$existing" \
      | jq --argjson desired ${lib.escapeShellArg desiredSettings} '. * $desired' \
      > "$tmp"

    mv -f "$tmp" "$file"
    chmod 644 "$file"
  '';
in
{
  # Vesktop reescreve settings.json em runtime; aplicar via merge na ativação
  # preserva preferências da UI e evita conflitos de .backup no Home Manager.
  home.activation.vesktopSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${vesktopSettingsMerge}
  '';
}