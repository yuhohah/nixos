{ pkgs, osConfig ? {}, ... }:

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
    config_file="$HOME/.config/quickshell/shell.toml"
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

  quickshellAgentUsageGemini = pkgs.writeScriptBin "quickshell-agent-usage-gemini" ''#!${pkgs.python3}/bin/python3
import os, sys, glob, json, datetime

brain_dir = os.path.expanduser("~/.gemini/antigravity-ide/brain")
state_dir = os.path.expanduser("~/.local/state/quickshell/agents")
usage_dir = os.path.join(state_dir, "usage")
config_file = os.path.expanduser("~/.config/quickshell/agents/gemini.json")
if not os.path.isfile(config_file):
    legacy_config = os.path.expanduser("~/.config/omarchy/agents/gemini.json")
    if os.path.isfile(legacy_config):
        config_file = legacy_config
history_file = os.path.join(state_dir, "gemini-history.jsonl")
if not os.path.isfile(history_file):
    legacy_hist = os.path.expanduser("~/.local/state/omarchy/agents/gemini-history.jsonl")
    if os.path.isfile(legacy_hist):
        history_file = legacy_hist

os.makedirs(usage_dir, exist_ok=True)

config = {}
if os.path.isfile(config_file):
    try:
        with open(config_file, "r") as f:
            config = json.load(f)
    except Exception:
        pass

now = datetime.datetime.now(datetime.timezone.utc)
local_now = datetime.datetime.now()
today_str = local_now.strftime("%Y-%m-%d")

dates = [(local_now - datetime.timedelta(days=i)).strftime("%Y-%m-%d") for i in range(6, -1, -1)]
recent_tokens = {d: 0 for d in dates}
recent_prompts = {d: 0 for d in dates}

total_prompts = 0
today_prompts = 0
today_sessions_set = set()
all_sessions = set()
active_dates = set()

today_tokens_by_model = {"gemini-2.5-pro": 0, "gemini-2.5-flash": 0}
model_usage = {
    "gemini-2.5-pro": {"inputTokens": 0, "outputTokens": 0, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0},
    "gemini-2.5-flash": {"inputTokens": 0, "outputTokens": 0, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0}
}

transcripts = glob.glob(os.path.join(brain_dir, "*", ".system_generated", "logs", "transcript.jsonl"))

for t_path in transcripts:
    conv_id = os.path.basename(os.path.dirname(os.path.dirname(os.path.dirname(t_path))))
    all_sessions.add(conv_id)
    session_has_today = False
    
    try:
        with open(t_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if not line.strip(): continue
                obj = json.loads(line)
                step_type = obj.get("type", "")
                created = obj.get("created_at", "")
                
                content = obj.get("content", "")
                thinking = obj.get("thinking", "")
                char_count = len(content) + len(thinking)
                step_tokens = max(1, char_count // 4)
                
                date_str = ""
                if created:
                    try:
                        dt = datetime.datetime.fromisoformat(created.replace("Z", "+00:00")).astimezone()
                        date_str = dt.strftime("%Y-%m-%d")
                    except Exception:
                        date_str = created[:10]
                        
                if date_str:
                    active_dates.add(date_str)
                    if date_str in recent_tokens:
                        recent_tokens[date_str] += step_tokens
                    if date_str == today_str:
                        session_has_today = True

                if step_type == "USER_INPUT":
                    total_prompts += 1
                    if date_str == today_str:
                        today_prompts += 1
                    if date_str in recent_prompts:
                        recent_prompts[date_str] += 1
                    model_usage["gemini-2.5-pro"]["inputTokens"] += step_tokens
                    if date_str == today_str:
                        today_tokens_by_model["gemini-2.5-pro"] += step_tokens
                elif step_type in ("MODEL_RESPONSE", "PLANNER_RESPONSE"):
                    model_usage["gemini-2.5-pro"]["outputTokens"] += step_tokens
                    if date_str == today_str:
                        today_tokens_by_model["gemini-2.5-pro"] += step_tokens
                else:
                    model_usage["gemini-2.5-flash"]["inputTokens"] += step_tokens
                    if date_str == today_str:
                        today_tokens_by_model["gemini-2.5-flash"] += step_tokens

        if session_has_today:
            today_sessions_set.add(conv_id)
    except Exception:
        pass

if os.path.isfile(history_file):
    try:
        with open(history_file, "r", encoding="utf-8") as f:
            for line in f:
                if not line.strip(): continue
                item = json.loads(line)
                d = item.get("date", today_str)
                in_tok = item.get("inputTokens", 0)
                out_tok = item.get("outputTokens", 0)
                m = item.get("model", "gemini-2.5-pro")
                if m not in model_usage:
                    model_usage[m] = {"inputTokens": 0, "outputTokens": 0, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0}
                if m not in today_tokens_by_model:
                    today_tokens_by_model[m] = 0
                
                model_usage[m]["inputTokens"] += in_tok
                model_usage[m]["outputTokens"] += out_tok
                tot = in_tok + out_tok
                if d in recent_tokens:
                    recent_tokens[d] += tot
                if d == today_str:
                    today_prompts += 1
                    today_tokens_by_model[m] += tot
                total_prompts += 1
                active_dates.add(d)
    except Exception:
        pass

today_total_tokens = sum(today_tokens_by_model.values())
recent_days = [{"date": d, "messageCount": recent_tokens[d]} for d in dates]

next_session_reset = (now + datetime.timedelta(hours=3)).strftime("%Y-%m-%dT%H:00:00Z")
days_until_sunday = (6 - now.weekday()) % 7 or 7
next_weekly_reset = (now + datetime.timedelta(days=days_until_sunday)).strftime("%Y-%m-%dT00:00:00Z")

session_pct = min(0.95, round(today_prompts / max(1, config.get("sessionLimit", 50)), 2))
weekly_prompts = sum(recent_prompts.values())
weekly_pct = min(0.95, round(weekly_prompts / max(1, config.get("weeklyLimit", 500)), 2))

record = {
    "id": "gemini",
    "name": config.get("name", "Google Gemini"),
    "ready": True,
    "tierLabel": config.get("tier", "Advanced"),
    "usageStatusText": "",
    "authHelpText": "",
    "limits": [
        {
            "label": "Session (5-hour)",
            "percent": session_pct,
            "resetsAt": next_session_reset
        },
        {
            "label": "Weekly (7-day)",
            "percent": weekly_pct,
            "resetsAt": next_weekly_reset
        }
    ],
    "todayPrompts": today_prompts,
    "todaySessions": len(today_sessions_set) or 1,
    "todayTotalTokens": today_total_tokens,
    "todayTokensByModel": today_tokens_by_model,
    "recentDays": recent_days,
    "totalPrompts": total_prompts,
    "totalSessions": len(all_sessions),
    "activeDays": len(active_dates),
    "modelUsage": model_usage
}

out_path = os.path.join(usage_dir, "gemini.json")
tmp_path = out_path + ".tmp"
with open(tmp_path, "w", encoding="utf-8") as f:
    json.dump(record, f, indent=2)
os.replace(tmp_path, out_path)
'';

  omarchyAgentUsageGemini = pkgs.writeShellScriptBin "omarchy-agent-usage-gemini" ''
    exec quickshell-agent-usage-gemini "$@"
  '';

  quickshellAgentUsageUpdate = pkgs.writeShellScriptBin "quickshell-agent-usage-update" ''
    USAGE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/agents/usage"
    mkdir -p "$USAGE_DIR"

    if command -v quickshell-agent-usage-gemini >/dev/null 2>&1; then
      quickshell-agent-usage-gemini "$@" || true
    fi
  '';

  omarchyAgentUsageUpdate = pkgs.writeShellScriptBin "omarchy-agent-usage-update" ''
    exec quickshell-agent-usage-update "$@"
  '';

  quickshellAgent = pkgs.writeShellScriptBin "quickshell-agent" ''
    action="$1"
    if [ "$action" = "--pick" ] || [ -z "$action" ]; then
      if command -v antigravity-ide >/dev/null 2>&1; then
        antigravity-ide "$HOME/Configuration/nixos" &
      elif command -v alacritty >/dev/null 2>&1; then
        alacritty -e gemini &
      fi
    elif [ "$action" = "gemini" ]; then
      if command -v antigravity-ide >/dev/null 2>&1; then
        antigravity-ide &
      else
        gemini
      fi
    fi
  '';

  omarchyAgent = pkgs.writeShellScriptBin "omarchy-agent" ''
    exec quickshell-agent "$@"
  '';

  diskSpeedtest = pkgs.writeShellScriptBin "disk-speedtest" ''
    TMPFILE="''${XDG_CACHE_HOME:-$HOME/.cache}/disk-speedtest.dat"
    cleanup() {
      rm -f "$TMPFILE" 2>/dev/null || true
      exit 0
    }
    trap cleanup INT TERM EXIT HUP

    # Identify root block device and model
    root_dev=$(${pkgs.coreutils}/bin/df / 2>/dev/null | ${pkgs.gawk}/bin/awk 'END {print $1}')
    disk_dev=$(${pkgs.util-linux}/bin/lsblk -no PKNAME "$root_dev" 2>/dev/null || true)
    [ -z "$disk_dev" ] && disk_dev=$(echo "$root_dev" | ${pkgs.gnused}/bin/sed -E 's/.*\/([a-z0-9]+)p?[0-9]+$/\1/')
    model=$(${pkgs.util-linux}/bin/lsblk -no MODEL "/dev/$disk_dev" 2>/dev/null | ${pkgs.findutils}/bin/xargs || true)
    [ -z "$model" ] && model="Disk ($disk_dev)"
    echo "disk $model"

    # Prepare 400MB test file for read testing
    ${pkgs.coreutils}/bin/dd if=/dev/zero of="$TMPFILE" bs=4M count=100 status=none conv=fdatasync 2>/dev/null

    calc_speed() {
      echo "$1" | ${pkgs.gawk}/bin/awk -F', ' '{
        for (i=1; i<=NF; i++) {
          if ($i ~ /bytes/) {
            split($i, a, " ")
            b = a[1]
          }
          if ($i ~ / s$/) {
            split($i, a, " ")
            s = a[1]
          }
        }
        if (s > 0) printf "%.1f\n", (b / 1000000) / s
      }'
    }

    # Read phase (4 live samples)
    for i in {1..4}; do
      res=$(LC_ALL=C ${pkgs.coreutils}/bin/dd if="$TMPFILE" of=/dev/null bs=4M iflag=direct 2>&1 || LC_ALL=C ${pkgs.coreutils}/bin/dd if="$TMPFILE" of=/dev/null bs=4M 2>&1)
      rate=$(calc_speed "$res")
      [ -n "$rate" ] && echo "read $rate"
      ${pkgs.coreutils}/bin/sleep 0.3
    done

    # Write phase (4 live samples)
    for i in {1..4}; do
      res=$(LC_ALL=C ${pkgs.coreutils}/bin/dd if=/dev/zero of="$TMPFILE" bs=4M count=100 oflag=direct conv=fdatasync 2>&1 || LC_ALL=C ${pkgs.coreutils}/bin/dd if=/dev/zero of="$TMPFILE" bs=4M count=100 conv=fdatasync 2>&1)
      rate=$(calc_speed "$res")
      [ -n "$rate" ] && echo "write $rate"
      ${pkgs.coreutils}/bin/sleep 0.3
    done
  '';

  omarchyDiskSpeedtest = pkgs.writeShellScriptBin "omarchy-disk-speedtest" ''
    exec disk-speedtest "$@"
  '';

  geminiCli = pkgs.writeScriptBin "gemini" ''#!${pkgs.python3}/bin/python3
import os, sys, json, urllib.request, urllib.error, datetime, readline

def get_api_key():
    if "GEMINI_API_KEY" in os.environ and os.environ["GEMINI_API_KEY"].strip():
        return os.environ["GEMINI_API_KEY"].strip()
    config_file = os.path.expanduser("~/.config/quickshell/agents/gemini.json")
    if not os.path.isfile(config_file):
        legacy = os.path.expanduser("~/.config/omarchy/agents/gemini.json")
        if os.path.isfile(legacy):
            config_file = legacy
    if os.path.isfile(config_file):
        try:
            with open(config_file, "r") as f:
                data = json.load(f)
                key = data.get("apiKey", "").strip()
                if key: return key
        except Exception:
            pass
    for path in ["~/.gemini/api_key", "~/.config/gemini/api_key"]:
        p = os.path.expanduser(path)
        if os.path.isfile(p):
            try:
                with open(p, "r") as f:
                    key = f.read().strip()
                    if key: return key
            except Exception:
                pass
    return None

def record_usage(input_tok, output_tok, model):
    state_dir = os.path.expanduser("~/.local/state/quickshell/agents")
    os.makedirs(state_dir, exist_ok=True)
    history_file = os.path.join(state_dir, "gemini-history.jsonl")
    entry = {
        "date": datetime.datetime.now().strftime("%Y-%m-%d"),
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "inputTokens": input_tok,
        "outputTokens": output_tok,
        "model": model
    }
    try:
        with open(history_file, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry) + "\n")
    except Exception:
        pass
    try:
        os.system("quickshell-agent-usage-gemini >/dev/null 2>&1 &")
    except Exception:
        pass

def call_gemini(messages, api_key, model="gemini-2.5-flash"):
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
    contents = []
    for m in messages:
        contents.append({"role": m["role"], "parts": [{"text": m["text"]}]})
    payload = json.dumps({"contents": contents}).encode("utf-8")
    req = urllib.request.Request(url, data=payload, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            candidate = data.get("candidates", [{}])[0]
            text = candidate.get("content", {}).get("parts", [{}])[0].get("text", "")
            usage = data.get("usageMetadata", {})
            in_tok = usage.get("promptTokenCount", max(1, len(messages[-1]["text"]) // 4))
            out_tok = usage.get("candidatesTokenCount", max(1, len(text) // 4))
            record_usage(in_tok, out_tok, model)
            return text
    except urllib.error.HTTPError as e:
        err = e.read().decode("utf-8", errors="ignore")
        return f"[Erro na API Gemini ({e.code})]: {err}"
    except Exception as e:
        return f"[Erro ao conectar]: {e}"

def main():
    api_key = get_api_key()
    if not api_key:
        print("\033[1;33m[Google Gemini CLI]\033[0m")
        print("Nenhuma chave de API encontrada.")
        print("Obtenha sua chave gratuitamente em: \033[1;34mhttps://aistudio.google.com/app/apikey\033[0m")
        print("\nPara configurar, faça uma das opções:")
        print("  1. export GEMINI_API_KEY='sua_chave'")
        print("  2. Adicione em ~/.config/quickshell/agents/gemini.json:")
        print('     { "apiKey": "sua_chave", "tier": "Pro" }')
        print("  3. Salve em ~/.gemini/api_key")
        sys.exit(1)

    model = "gemini-2.5-flash"

    if len(sys.argv) > 1:
        prompt = " ".join(sys.argv[1:])
        messages = [{"role": "user", "text": prompt}]
        response = call_gemini(messages, api_key, model)
        print(response)
        return

    print(f"\033[1;36m✦ Google Gemini CLI ({model}) - Digite 'sair' ou Ctrl+C para encerrar\033[0m\n")
    history = []
    while True:
        try:
            prompt = input("\033[1;32mVocê > \033[0m").strip()
            if not prompt: continue
            if prompt.lower() in ("sair", "exit", "quit"): break
            
            history.append({"role": "user", "text": prompt})
            print("\033[1;35mGemini...\033[0m", end="\r", flush=True)
            response = call_gemini(history, api_key, model)
            print(" " * 20, end="\r")
            print(f"\033[1;34mGemini > \033[0m{response}\n")
            history.append({"role": "model", "text": response})
            if len(history) > 20: history = history[-20:]
        except (KeyboardInterrupt, EOFError):
            print("\nAté logo!")
            break

if __name__ == "__main__":
    main()
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
    pkgs.python3
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
    quickshellAgentUsageGemini
    omarchyAgentUsageGemini
    quickshellAgentUsageUpdate
    omarchyAgentUsageUpdate
    quickshellAgent
    omarchyAgent
    diskSpeedtest
    omarchyDiskSpeedtest
    geminiCli
  ];

  xdg.configFile."quickshell" = {
    source = quickshellConfig;
    force = true;
  };
}
