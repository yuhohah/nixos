{ config, pkgs, osConfig ? {}, lib, ... }:

let
  hostname = osConfig.networking.hostName or "nixos-btw";

  hostShellJson =
    if hostname == "arrow"
    then ./hosts/arrow/shell.json
    else ./hosts/nixos-btw/shell.json;

  quickshellConfig = pkgs.runCommand "quickshell-config" {} ''
    mkdir -p $out
    cp -r ${./src}/* $out/
    chmod -R u+w $out
    cp -f ${hostShellJson} $out/shell.json
  '';
  quickshellToggle = pkgs.writeShellScriptBin "quickshell-toggle" ''
    if pgrep -f "quickshell" > /dev/null 2>&1; then
      pkill -f "quickshell"
    else
      ${pkgs.quickshell}/bin/quickshell &
    fi
  '';

  bluetoothDevice = pkgs.writeShellScriptBin "bluetooth-device" ''
    action="$1"
    address="$2"

    if [ -z "$action" ] || [ -z "$address" ]; then
      echo "Usage: bluetooth-device <connect|disconnect|pair|forget> <address>" >&2
      exit 1
    fi

    case "$action" in
      connect)
        ${pkgs.bluez}/bin/bluetoothctl trust "$address" 2>/dev/null || true
        ${pkgs.bluez}/bin/bluetoothctl connect "$address"
        ;;
      disconnect)
        ${pkgs.bluez}/bin/bluetoothctl disconnect "$address"
        ;;
      pair)
        ${pkgs.bluez}/bin/bluetoothctl pairable on 2>/dev/null || true
        ${pkgs.bluez}/bin/bluetoothctl pair "$address"
        ${pkgs.bluez}/bin/bluetoothctl trust "$address" 2>/dev/null || true
        ${pkgs.bluez}/bin/bluetoothctl connect "$address"
        ;;
      forget|remove)
        ${pkgs.bluez}/bin/bluetoothctl disconnect "$address" 2>/dev/null || true
        ${pkgs.bluez}/bin/bluetoothctl untrust "$address" 2>/dev/null || true
        ${pkgs.bluez}/bin/bluetoothctl remove "$address"
        ;;
      *)
        echo "Unknown action: $action" >&2
        exit 1
        ;;
    esac
  '';

  bluetoothPower = pkgs.writeShellScriptBin "bluetooth-power" ''
    state="$1"
    case "$state" in
      on)
        ${pkgs.util-linux}/bin/rfkill unblock bluetooth 2>/dev/null || true
        ${pkgs.bluez}/bin/bluetoothctl power on
        ;;
      off)
        ${pkgs.bluez}/bin/bluetoothctl power off
        ${pkgs.util-linux}/bin/rfkill block bluetooth 2>/dev/null || true
        ;;
      *)
        echo "Usage: bluetooth-power <on|off>" >&2
        exit 1
        ;;
    esac
  '';

  audioSetDefault = pkgs.writeShellScriptBin "audio-output-set-default" ''
    id="$1"
    if [ -n "$id" ]; then
      ${pkgs.wireplumber}/bin/wpctl set-default "$id" 2>/dev/null || true
    fi
  '';

  audioSink = pkgs.writeShellScriptBin "audio-output-sink" ''
    ${pkgs.wireplumber}/bin/wpctl status 2>/dev/null | grep -E '\*\s+[0-9]+\.' | head -n1 || echo ""
  '';

  networkStatus = pkgs.writeShellScriptBin "network-status" ''
    default_route=$(${pkgs.iproute2}/bin/ip route show default 2>/dev/null | head -n1)
    iface=$(echo "$default_route" | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')
    gateway=$(echo "$default_route" | awk '{for(i=1;i<=NF;i++) if($i=="via") print $(i+1)}')

    if [ -z "$iface" ]; then
      if [ "$1" = "--verbose" ]; then
        echo -e "type\tdisconnected"
      else
        echo -e "disconnected\t\t\t"
      fi
      exit 0
    fi

    if [ -d "/sys/class/net/$iface/wireless" ] || [ -f "/proc/net/wireless" ] && grep -q "$iface:" /proc/net/wireless 2>/dev/null; then
      type="wifi"
    else
      type="ethernet"
    fi

    ip_info=$(${pkgs.iproute2}/bin/ip -4 -o addr show dev "$iface" 2>/dev/null | head -n1 | awk '{print $4}')
    ip_addr="''${ip_info%/*}"
    prefix="''${ip_info#*/}"

    rx_bytes=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || echo "0")
    tx_bytes=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || echo "0")
    duplex=$(cat "/sys/class/net/$iface/duplex" 2>/dev/null || echo "full")
    speed=$(cat "/sys/class/net/$iface/speed" 2>/dev/null || echo "0")

    ssid=""
    signal="0"
    freq=""
    bitrate=""

    if [ "$type" = "wifi" ]; then
      wifi_line=$(${pkgs.networkmanager}/bin/nmcli -t -f active,ssid,signal,freq,rate dev wifi 2>/dev/null | grep -E '^(\*|yes|sim|true):' | head -n1)
      if [ -n "$wifi_line" ]; then
        ssid=$(echo "$wifi_line" | cut -d: -f2)
        signal=$(echo "$wifi_line" | cut -d: -f3)
        freq=$(echo "$wifi_line" | cut -d: -f4 | awk '{print $1}')
        bitrate=$(echo "$wifi_line" | cut -d: -f5)
      else
        ssid=$(${pkgs.networkmanager}/bin/nmcli -t -f active,ssid dev wifi 2>/dev/null | grep -E '^(\*|yes|sim|true):' | head -n1 | cut -d: -f2)
      fi
      [ -z "$speed" ] || [ "$speed" = "0" ] && speed="''${bitrate%% *}"
    else
      ssid="Ethernet"
    fi

    if [ "$1" = "--verbose" ]; then
      router_ping=""
      if [ -n "$gateway" ]; then
        router_ping=$(${pkgs.iputils}/bin/ping -c 1 -W 1 "$gateway" 2>/dev/null | grep 'time=' | sed -E 's/.*time=([0-9.]+).*/\1/' || true)
      fi
      internet_ping=$(${pkgs.iputils}/bin/ping -c 1 -W 1 1.1.1.1 2>/dev/null | grep 'time=' | sed -E 's/.*time=([0-9.]+).*/\1/' || true)

      printf "iface\t%s\n" "$iface"
      printf "type\t%s\n" "$type"
      printf "ip\t%s\n" "$ip_addr"
      printf "prefix\t%s\n" "$prefix"
      printf "gateway\t%s\n" "$gateway"
      printf "speed\t%s\n" "$speed"
      printf "duplex\t%s\n" "$duplex"
      printf "ssid\t%s\n" "$ssid"
      printf "signal\t%s\n" "$signal"
      printf "freq\t%s\n" "$freq"
      printf "bitrate\t%s\n" "$bitrate"
      printf "rx_bytes\t%s\n" "$rx_bytes"
      printf "tx_bytes\t%s\n" "$tx_bytes"
      [ -n "$router_ping" ] && printf "router_ping_ms\t%s\n" "$router_ping"
      [ -n "$internet_ping" ] && printf "internet_ping_ms\t%s\n" "$internet_ping"
    else
      printf "%s\t%s\t%s\t%s\n" "$type" "$ssid" "$signal" "$freq"
    fi
  '';

  networkDns = pkgs.writeShellScriptBin "network-dns" ''
    provider="$1"
    custom_dns="$2"

    con=$(${pkgs.networkmanager}/bin/nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep -E ':(802-11-wireless|802-3-ethernet|wifi|ethernet)' | head -n1 | cut -d: -f1)

    if [ -z "$provider" ]; then
      if [ -z "$con" ]; then
        echo "DHCP"
        exit 0
      fi
      dns_setting=$(${pkgs.networkmanager}/bin/nmcli -g ipv4.dns connection show "$con" 2>/dev/null)
      ignore_auto=$(${pkgs.networkmanager}/bin/nmcli -g ipv4.ignore-auto-dns connection show "$con" 2>/dev/null)

      if [ "$ignore_auto" != "yes" ] || [ -z "$dns_setting" ]; then
        echo "DHCP"
      elif echo "$dns_setting" | grep -q "1.1.1.1"; then
        echo "Cloudflare"
      elif echo "$dns_setting" | grep -q "8.8.8.8"; then
        echo "Google"
      else
        echo "Custom"
      fi
      exit 0
    fi

    if [ -z "$con" ]; then
      echo "No active connection to set DNS" >&2
      exit 1
    fi

    case "$provider" in
      DHCP)
        ${pkgs.networkmanager}/bin/nmcli connection modify "$con" ipv4.ignore-auto-dns no ipv4.dns "" 2>/dev/null || true
        ${pkgs.networkmanager}/bin/nmcli connection modify "$con" ipv6.ignore-auto-dns no ipv6.dns "" 2>/dev/null || true
        ${pkgs.networkmanager}/bin/nmcli connection up "$con" >/dev/null 2>&1
        ;;
      Cloudflare)
        ${pkgs.networkmanager}/bin/nmcli connection modify "$con" ipv4.ignore-auto-dns yes ipv4.dns "1.1.1.1 1.0.0.1" 2>/dev/null || true
        ${pkgs.networkmanager}/bin/nmcli connection modify "$con" ipv6.ignore-auto-dns yes ipv6.dns "2606:4700:4700::1111 2606:4700:4700::1001" 2>/dev/null || true
        ${pkgs.networkmanager}/bin/nmcli connection up "$con" >/dev/null 2>&1
        ;;
      Google)
        ${pkgs.networkmanager}/bin/nmcli connection modify "$con" ipv4.ignore-auto-dns yes ipv4.dns "8.8.8.8 8.8.4.4" 2>/dev/null || true
        ${pkgs.networkmanager}/bin/nmcli connection modify "$con" ipv6.ignore-auto-dns yes ipv6.dns "2001:4860:4860::8888 2001:4860:4860::8844" 2>/dev/null || true
        ${pkgs.networkmanager}/bin/nmcli connection up "$con" >/dev/null 2>&1
        ;;
      Custom)
        if [ -n "$custom_dns" ]; then
          ${pkgs.networkmanager}/bin/nmcli connection modify "$con" ipv4.ignore-auto-dns yes ipv4.dns "$custom_dns" 2>/dev/null || true
          ${pkgs.networkmanager}/bin/nmcli connection up "$con" >/dev/null 2>&1
        fi
        ;;
      *)
        echo "Unknown provider: $provider" >&2
        exit 1
        ;;
    esac
  '';

  networkBand = pkgs.writeShellScriptBin "network-band" ''
    target="$1"
    wifi_line=$(${pkgs.networkmanager}/bin/nmcli -t -f active,ssid,freq dev wifi 2>/dev/null | grep -E '^(\*|yes|sim|true):' | head -n1)
    current_freq=$(echo "$wifi_line" | cut -d: -f3 | awk '{print $1}')
    
    current_band=""
    if [ -n "$current_freq" ]; then
      if [ "$current_freq" -gt 5000 ]; then
        current_band="5"
      else
        current_band="2.4"
      fi
    fi

    if [ -z "$target" ]; then
      printf "band\t%s\n" "$current_band"
      printf "selected\tauto\n"
      printf "available\t2.4 5\n"
      exit 0
    fi
  '';

  networkSpeedtest = pkgs.writeShellScriptBin "network-speedtest" ''
    phase="$1"
    if [ -z "$phase" ]; then
      phase="down"
    fi

    default_route=$(${pkgs.iproute2}/bin/ip route show default 2>/dev/null | head -n1)
    iface=$(echo "$default_route" | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')

    if [ -z "$iface" ] || [ ! -d "/sys/class/net/$iface" ]; then
      echo "No active network interface" >&2
      exit 1
    fi

    pids=()
    cleanup() {
      for pid in "''${pids[@]}"; do
        kill -9 "$pid" 2>/dev/null || true
      done
      exit 0
    }
    trap cleanup SIGINT SIGTERM SIGHUP EXIT

    if [ "$phase" = "down" ]; then
      for _ in {1..3}; do
        (
          while true; do
            ${pkgs.curl}/bin/curl -s -H "User-Agent: Mozilla/5.0" -H "Referer: https://speed.cloudflare.com/" "https://speed.cloudflare.com/__down?bytes=50000000" > /dev/null 2>&1 || sleep 0.2
          done
        ) &
        pids+=($!)
      done

      t0=$(date +%s%N)
      b0=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || echo 0)

      while true; do
        sleep 0.25
        t1=$(date +%s%N)
        b1=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || echo 0)
        dt=$(( t1 - t0 ))
        db=$(( b1 - b0 ))
        t0=$t1
        b0=$b1
        if [ "$dt" -gt 0 ] && [ "$db" -ge 0 ]; then
          ${pkgs.gawk}/bin/awk "BEGIN { printf \"%.1f\n\", ($db * 8000) / $dt }"
        fi
      done

    elif [ "$phase" = "up" ]; then
      for _ in {1..3}; do
        (
          while true; do
            head -c 10000000 /dev/zero | ${pkgs.curl}/bin/curl -s -H "User-Agent: Mozilla/5.0" -H "Referer: https://speed.cloudflare.com/" -X POST --data-binary @- "https://speed.cloudflare.com/__up" > /dev/null 2>&1 || sleep 0.2
          done
        ) &
        pids+=($!)
      done

      t0=$(date +%s%N)
      b0=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || echo 0)

      while true; do
        sleep 0.25
        t1=$(date +%s%N)
        b1=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || echo 0)
        dt=$(( t1 - t0 ))
        db=$(( b1 - b0 ))
        t0=$t1
        b0=$b1
        if [ "$dt" -gt 0 ] && [ "$db" -ge 0 ]; then
          ${pkgs.gawk}/bin/awk "BEGIN { printf \"%.1f\n\", ($db * 8000) / $dt }"
        fi
      done
    fi
  '';

  networkPassword = pkgs.writeShellScriptBin "network-password" ''
    iface="$1"
    if [ -z "$iface" ]; then
      iface=$(${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,TYPE dev 2>/dev/null | grep ':wifi' | head -n1 | cut -d: -f1)
    fi

    con=$(${pkgs.networkmanager}/bin/nmcli -t -f NAME,DEVICE,TYPE connection show --active 2>/dev/null | grep -E ':(802-11-wireless|wifi)' | head -n1 | cut -d: -f1)
    if [ -z "$con" ] && [ -n "$iface" ]; then
      con=$(${pkgs.networkmanager}/bin/nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null | grep ":$iface$" | head -n1 | cut -d: -f1)
    fi

    if [ -z "$con" ]; then
      echo "No active Wi-Fi connection found" >&2
      exit 1
    fi

    password=$(${pkgs.networkmanager}/bin/nmcli -s -g 802-11-wireless-security.psk connection show "$con" 2>/dev/null)
    if [ -z "$password" ]; then
      password=$(${pkgs.networkmanager}/bin/nmcli -s -g 802-11-wireless-security.wep-key0 connection show "$con" 2>/dev/null)
    fi

    if [ -z "$password" ]; then
      echo "Could not find password for connection $con" >&2
      exit 1
    fi

    echo "$password"
  '';

  networkQr = pkgs.writeShellScriptBin "network-qr" ''
    meta_flag=false
    iface=""

    for arg in "$@"; do
      if [ "$arg" = "--meta" ]; then
        meta_flag=true
      elif [ -z "$iface" ]; then
        iface="$arg"
      fi
    done

    if [ -z "$iface" ]; then
      default_route=$(${pkgs.iproute2}/bin/ip route show default 2>/dev/null | head -n1)
      iface=$(echo "$default_route" | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')
      if [ -z "$iface" ] || [ ! -d "/sys/class/net/$iface/wireless" ]; then
        iface=$(${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,TYPE dev 2>/dev/null | grep ':wifi' | head -n1 | cut -d: -f1)
      fi
    fi

    con=$(${pkgs.networkmanager}/bin/nmcli -t -f NAME,DEVICE,TYPE connection show --active 2>/dev/null | grep -E ':(802-11-wireless|wifi)' | head -n1 | cut -d: -f1)
    if [ -z "$con" ] && [ -n "$iface" ]; then
      con=$(${pkgs.networkmanager}/bin/nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null | grep ":$iface$" | head -n1 | cut -d: -f1)
    fi

    wifi_line=$(${pkgs.networkmanager}/bin/nmcli -t -f active,ssid,security dev wifi 2>/dev/null | grep -E '^(\*|yes|sim|true):' | head -n1)
    ssid=$(echo "$wifi_line" | cut -d: -f2)
    sec_raw=$(echo "$wifi_line" | cut -d: -f3)

    if [ -z "$ssid" ] && [ -n "$con" ]; then
      ssid=$(${pkgs.networkmanager}/bin/nmcli -g 802-11-wireless.ssid connection show "$con" 2>/dev/null)
      [ -z "$ssid" ] && ssid="$con"
    fi

    if [ -z "$ssid" ]; then
      echo "No active Wi-Fi connection to share" >&2
      exit 1
    fi

    password=""
    sec_type="WPA"

    if [ -z "$sec_raw" ] || [ "$sec_raw" = "--" ]; then
      sec_type="nopass"
    elif echo "$sec_raw" | grep -qi "wep"; then
      sec_type="WEP"
      if [ -n "$con" ]; then
        password=$(${pkgs.networkmanager}/bin/nmcli -s -g 802-11-wireless-security.wep-key0 connection show "$con" 2>/dev/null)
      fi
    else
      sec_type="WPA"
      if [ -n "$con" ]; then
        password=$(${pkgs.networkmanager}/bin/nmcli -s -g 802-11-wireless-security.psk connection show "$con" 2>/dev/null)
      fi
    fi

    escape_qr() {
      echo -n "$1" | sed 's/\\/\\\\/g; s/;/\\;/g; s/,/\\,/g; s/:/\\:/g; s/"/\\"/g'
    }

    esc_ssid=$(escape_qr "$ssid")
    if [ "$sec_type" = "nopass" ] || [ -z "$password" ]; then
      qr_data="WIFI:T:nopass;S:$esc_ssid;;"
    else
      esc_pass=$(escape_qr "$password")
      qr_data="WIFI:T:$sec_type;S:$esc_ssid;P:$esc_pass;;"
    fi

    if [ "$meta_flag" = true ]; then
      printf "meta\t%s\t%s\t%s\n" "$iface" "$sec_type" "$ssid"
    fi

    ${pkgs.qrencode}/bin/qrencode -m 0 -t ASCII "$qr_data" | sed 's/#/1/g; s/ /0/g; s/11/1/g; s/00/0/g'
  '';

  networkVpn = pkgs.writeShellScriptBin "network-vpn" ''
    action="''${1:-status}"

    con=$(${pkgs.networkmanager}/bin/nmcli -t -f NAME,TYPE connection show 2>/dev/null | grep -E ':(wireguard|vpn)' | head -n1 | cut -d: -f1)
    [ -z "$con" ] && con="proton"

    case "$action" in
      status)
        if ${pkgs.networkmanager}/bin/nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep -E "^$con:(wireguard|vpn)" >/dev/null 2>&1; then
          echo "connected"
        else
          echo "disconnected"
        fi
        ;;
      toggle)
        if ${pkgs.networkmanager}/bin/nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep -E "^$con:(wireguard|vpn)" >/dev/null 2>&1; then
          ${pkgs.networkmanager}/bin/nmcli connection down "$con" >/dev/null 2>&1
          echo "disconnected"
        else
          ${pkgs.networkmanager}/bin/nmcli connection up "$con" >/dev/null 2>&1
          echo "connected"
        fi
        ;;
      connect)
        ${pkgs.networkmanager}/bin/nmcli connection up "$con" >/dev/null 2>&1
        echo "connected"
        ;;
      disconnect)
        ${pkgs.networkmanager}/bin/nmcli connection down "$con" >/dev/null 2>&1
        echo "disconnected"
        ;;
      name)
        echo "$con"
        ;;
      *)
        echo "Usage: network-vpn <status|toggle|connect|disconnect|name>" >&2
        exit 1
        ;;
    esac
  '';

  batteryStatus = pkgs.writeShellScriptBin "battery-status" ''
    bat_dir=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)

    if [ -z "$bat_dir" ] || [ ! -d "$bat_dir" ]; then
      exit 0
    fi

    capacity=$(cat "$bat_dir/capacity" 2>/dev/null || echo "")
    status=$(cat "$bat_dir/status" 2>/dev/null || echo "")
    cycle_count=$(cat "$bat_dir/cycle_count" 2>/dev/null || echo "")
    charge_now=$(cat "$bat_dir/charge_now" 2>/dev/null || cat "$bat_dir/energy_now" 2>/dev/null || echo "")
    charge_full=$(cat "$bat_dir/charge_full" 2>/dev/null || cat "$bat_dir/energy_full" 2>/dev/null || echo "")
    voltage_now=$(cat "$bat_dir/voltage_now" 2>/dev/null || echo "")
    current_now=$(cat "$bat_dir/current_now" 2>/dev/null || cat "$bat_dir/power_now" 2>/dev/null || echo "")
    threshold=$(cat "$bat_dir/charge_control_end_threshold" 2>/dev/null || echo "")

    size_wh=""
    if [ -n "$charge_full" ] && [ -n "$voltage_now" ] && [ "$voltage_now" -gt 0 ] 2>/dev/null; then
      size_wh=$(${pkgs.gawk}/bin/awk "BEGIN { printf \"%.1f Wh\", ($charge_full * $voltage_now) / 1000000000000 }" 2>/dev/null || echo "")
    fi

    rate_w=""
    if [ -n "$current_now" ] && [ "$current_now" -gt 0 ] 2>/dev/null; then
      if [ -n "$voltage_now" ] && [ "$voltage_now" -gt 0 ] 2>/dev/null; then
        rate_w=$(${pkgs.gawk}/bin/awk "BEGIN { printf \"%.1f W\", ($current_now * $voltage_now) / 1000000000000 }" 2>/dev/null || echo "")
      fi
    fi

    time_str="—"
    if [ -n "$current_now" ] && [ "$current_now" -gt 0 ] 2>/dev/null && [ -n "$charge_now" ]; then
      if [ "$status" = "Discharging" ]; then
        mins=$(( (charge_now * 60) / current_now ))
        time_str="$(( mins / 60 ))h $(( mins % 60 ))m"
      elif [ "$status" = "Charging" ] && [ -n "$charge_full" ]; then
        remaining=$(( charge_full - charge_now ))
        if [ "$remaining" -gt 0 ]; then
          mins=$(( (remaining * 60) / current_now ))
          time_str="$(( mins / 60 ))h $(( mins % 60 ))m"
        fi
      fi
    fi

    if [ "$1" = "--shell" ] || [ "$1" = "--verbose" ]; then
      [ -n "$capacity" ] && printf "percentage\t%s%%\n" "$capacity"
      [ -n "$size_wh" ] && printf "size\t%s\n" "$size_wh"
      [ -n "$cycle_count" ] && printf "cycles\t%s\n" "$cycle_count"
      [ -n "$time_str" ] && printf "time\t%s\n" "$time_str"
      [ -n "$rate_w" ] && printf "rate\t%s\n" "$rate_w"
      [ -n "$threshold" ] && printf "threshold\t%s%%\n" "$threshold"
    else
      printf "%s\t%s\n" "$capacity" "$status"
    fi
  '';

  powerprofilesList = pkgs.writeShellScriptBin "powerprofiles-list" ''
    if command -v powerprofilesctl >/dev/null 2>&1; then
      active=$(powerprofilesctl get 2>/dev/null || echo "balanced")
      for p in power-saver balanced performance; do
        if [ "$p" = "$active" ]; then
          printf "%s\t1\n" "$p"
        else
          printf "%s\t0\n" "$p"
        fi
      done
    else
      printf "power-saver\t0\n"
      printf "balanced\t1\n"
      printf "performance\t0\n"
    fi
  '';

  powerprofilesSet = pkgs.writeShellScriptBin "powerprofiles-set" ''
    profile="$2"
    [ -z "$profile" ] && profile="$1"

    if command -v powerprofilesctl >/dev/null 2>&1; then
      powerprofilesctl set "$profile" 2>/dev/null || true
    elif command -v tlp >/dev/null 2>&1; then
      if [ "$profile" = "power-saver" ]; then
        tlp bat 2>/dev/null || true
      else
        tlp ac 2>/dev/null || true
      fi
    fi
  '';

  systemStats = pkgs.writeShellScriptBin "system-stats" ''
    cpu_temp=""
    if [ -d "/sys/class/thermal" ]; then
      temp_raw=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | sort -nr | head -n1)
      if [ -n "$temp_raw" ] && [ "$temp_raw" -gt 0 ] 2>/dev/null; then
        cpu_temp=$(${pkgs.gawk}/bin/awk "BEGIN { printf \"%.0f°C\", $temp_raw / 1000 }")
      fi
    fi

    uptime_str=""
    if [ -f "/proc/uptime" ]; then
      up_secs=$(cut -d. -f1 /proc/uptime)
      days=$(( up_secs / 86400 ))
      hours=$(( (up_secs % 86400) / 3600 ))
      mins=$(( (up_secs % 3600) / 60 ))
      if [ "$days" -gt 0 ]; then
        uptime_str="''${days}d ''${hours}h"
      elif [ "$hours" -gt 0 ]; then
        uptime_str="''${hours}h ''${mins}m"
      else
        uptime_str="''${mins}m"
      fi
    fi

    [ -n "$cpu_temp" ] && printf "temperature\t%s\n" "$cpu_temp"
    [ -n "$uptime_str" ] && printf "uptime\t%s\n" "$uptime_str"
  '';

  monitorState = pkgs.writeShellScriptBin "monitor-state" ''
    brightness="unavailable"
    if command -v brightnessctl >/dev/null 2>&1; then
      b=$(${pkgs.brightnessctl}/bin/brightnessctl -m 2>/dev/null | head -n1 | cut -d, -f4 | tr -d '%')
      [ -n "$b" ] && brightness="$b"
    elif [ -d "/sys/class/backlight" ]; then
      b_dir=$(ls -d /sys/class/backlight/* 2>/dev/null | head -n1)
      if [ -n "$b_dir" ]; then
        cur=$(cat "$b_dir/brightness" 2>/dev/null || echo 100)
        max=$(cat "$b_dir/max_brightness" 2>/dev/null || echo 100)
        [ "$max" -gt 0 ] && brightness=$(( (cur * 100) / max ))
      fi
    fi

    monitors_json=$(${pkgs.hyprland}/bin/hyprctl -j monitors all 2>/dev/null || echo "[]")
    internal_mon=$(echo "$monitors_json" | ${pkgs.jq}/bin/jq -r '([.[] | select(.name | test("^(eDP|LVDS)"))] | .[0].name) // (.[0].name // "")' 2>/dev/null)
    external_mon=$(echo "$monitors_json" | ${pkgs.jq}/bin/jq -r '([.[] | select(.name | test("^(eDP|LVDS)") | not)] | .[0].name) // ""' 2>/dev/null)
    internal_enabled=$(echo "$monitors_json" | ${pkgs.jq}/bin/jq -r "([.[] | select(.name == \"$internal_mon\" and .disabled == false)] | .[0].name) // \"\"" 2>/dev/null)
    mirror_enabled=$(echo "$monitors_json" | ${pkgs.jq}/bin/jq -r '([.[] | select(.mirrorOf != "none" and .mirrorOf != "")] | .[0].name) // ""' 2>/dev/null)
    focused_mon=$(echo "$monitors_json" | ${pkgs.jq}/bin/jq -r '([.[] | select(.focused == true)] | .[0].name) // (.[0].name // "")' 2>/dev/null)
    focused_scale=$(echo "$monitors_json" | ${pkgs.jq}/bin/jq -r '([.[] | select(.focused == true)] | .[0].scale) // (.[0].scale // 1)' 2>/dev/null)
    displays_json=$(echo "$monitors_json" | ${pkgs.jq}/bin/jq -c '[.[] | {name: .name, description: .description, focused: .focused, enabled: (.disabled | not), width: .width, height: .height, scale: .scale}]' 2>/dev/null)

    [ -z "$displays_json" ] && displays_json="[]"

    echo "$brightness"
    echo "$internal_mon"
    echo "$external_mon"
    echo "$internal_enabled"
    echo "$mirror_enabled"
    echo "$focused_mon"
    echo "$focused_scale"
    echo "$displays_json"
  '';

  monitorScaling = pkgs.writeShellScriptBin "monitor-scaling" ''
    scale="$1"
    if [ -z "$scale" ]; then
      echo "Usage: monitor-scaling <scale>" >&2
      exit 1
    fi
    monitors_json=$(${pkgs.hyprland}/bin/hyprctl -j monitors 2>/dev/null || echo "[]")
    focused_mon=$(echo "$monitors_json" | ${pkgs.jq}/bin/jq -r '([.[] | select(.focused == true)] | .[0].name) // (.[0].name // "")' 2>/dev/null)
    [ -z "$focused_mon" ] && focused_mon="eDP-1"
    ${pkgs.hyprland}/bin/hyprctl keyword monitor "$focused_mon,preferred,auto,$scale"
  '';

  displayTextSize = pkgs.writeShellScriptBin "display-text-size" ''
    size="''${1:-12}"
    config_file="$HOME/.config/omarchy/shell.toml"
    mkdir -p "$(dirname "$config_file")"

    if [ ! -f "$config_file" ]; then
      cat <<EOF > "$config_file"
[font]
base-size = $size
EOF
    else
      if grep -q "^\[font\]" "$config_file"; then
        if grep -q "^base-size" "$config_file"; then
          sed -i "s/^base-size *= *.*/base-size = $size/" "$config_file"
        else
          sed -i "/^\[font\]/a base-size = $size" "$config_file"
        fi
      else
        cat <<EOF >> "$config_file"

[font]
base-size = $size
EOF
      fi
    fi

    if command -v gsettings >/dev/null 2>&1; then
      scale=$(${pkgs.gawk}/bin/awk -v s="$size" 'BEGIN { printf "%.2f", s / 12 }')
      gsettings set org.gnome.desktop.interface text-scaling-factor "$scale" 2>/dev/null || true
    fi
  '';
in
{
  home.packages = [
    pkgs.quickshell
    pkgs.inotify-tools
    pkgs.libxkbcommon
    pkgs.qrencode
    pkgs.gawk
    pkgs.btop
    pkgs.jq
    pkgs.brightnessctl
    quickshellToggle
    bluetoothDevice
    bluetoothPower
    audioSetDefault
    audioSink
    networkStatus
    networkDns
    networkBand
    networkSpeedtest
    networkQr
    networkPassword
    networkVpn
    batteryStatus
    powerprofilesList
    powerprofilesSet
    systemStats
    monitorState
    monitorScaling
    displayTextSize
  ];

  xdg.configFile."quickshell".source = quickshellConfig;
}
