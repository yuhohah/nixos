{ config, pkgs, ... }:

let
  quickshellToggle = pkgs.writeShellScriptBin "quickshell-toggle" ''
    if pgrep -f "quickshell" > /dev/null 2>&1; then
      pkill -f "quickshell"
    else
      ${pkgs.quickshell}/bin/quickshell &
    fi
  '';

  quickshellStats = pkgs.writeShellScriptBin "quickshell-stats" ''
    mem=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf "%.1f", (t-a)/1048576}' /proc/meminfo)
    cpu=$(awk '/^cpu / {u=$2+$4; t=$2+$4+$5; if(NR==1){u1=u; t1=t} else {print int((u-u1)*100/(t-t1))}}' <(head -n1 /proc/stat; sleep 0.1; head -n1 /proc/stat))
    wifi=$(awk 'NR==3 {sub(/\./,"",$3); print int($3*100/70)}' /proc/net/wireless 2>/dev/null)
    vol_raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    vol=$(echo "$vol_raw" | awk '{print int($2*100)}')
    muted=$(echo "$vol_raw" | grep -q "MUTED" && echo "true" || echo "false")
    echo "{\"cpu\":''${cpu:-0},\"mem\":\"''${mem:-0.0}\",\"wifi\":''${wifi:-0},\"vol\":''${vol:-0},\"muted\":''${muted}}"
  '';
in
{
  home.packages = [
    pkgs.quickshell
    quickshellToggle
    quickshellStats
  ];

  xdg.configFile."quickshell/shell.qml".source = ./shell.qml;
}
