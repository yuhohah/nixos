#!/usr/bin/env bash

# Monitor de bateria para o ambiente #arrow
# Avisa em 20% e 10%

# Arquivo temporário para evitar spam de notificações
#!/usr/bin/env bash

STATE_FILE="/tmp/battery_alert_state"
touch "$STATE_FILE"

# Otimização 1: Descobre o caminho da bateria APENAS UMA VEZ
BATTERY_PATH=$(find /sys/class/power_supply/ -name "BAT*" | head -n 1)

# Se não encontrar bateria, encerra para não rodar um loop inútil
if [ -z "$BATTERY_PATH" ]; then
    exit 1
fi

while true; do
    # Otimização 2: Leitura direta de arquivos sem subprocessos
    if [ -f "$BATTERY_PATH/capacity" ]; then
        read -r CAPACITY < "$BATTERY_PATH/capacity"
        read -r STATUS < "$BATTERY_PATH/status"
        
        if [ "$STATUS" = "Discharging" ]; then
            if [ "$CAPACITY" -le 10 ]; then
                if ! grep -q "10" "$STATE_FILE"; then
                    notify-send -u critical "🪫 Bateria Crítica!" "Status: ${CAPACITY}%"
                    echo "10" > "$STATE_FILE"
                fi
            elif [ "$CAPACITY" -le 20 ]; then
                if ! grep -q "20" "$STATE_FILE"; then
                    notify-send -u normal "🔋 Bateria Baixa" "Status: ${CAPACITY}%"
                    echo "20" > "$STATE_FILE"
                fi
            fi
        else
            # Reseta se estiver carregando ou cheia
            > "$STATE_FILE"
        fi
    fi
    
    sleep 60
done