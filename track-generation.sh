#!/usr/bin/env bash
# track-generation.sh
# Rastreia o número total de generations do NixOS entre múltiplos hosts.
# Deve ser chamado após cada nixos-rebuild switch/boot/test.
#
# Uso: ./track-generation.sh [--host HOSTNAME]
#
# Coloque este script no mesmo diretório que configuration.nix.
# O arquivo generations.json é o banco de dados persistente — faça backup dele!

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_FILE="${SCRIPT_DIR}/generations.json"
HOSTNAME="${1:-$(hostname)}"

# Se passar --host NOME como argumento
if [[ "${1:-}" == "--host" && -n "${2:-}" ]]; then
    HOSTNAME="$2"
fi

# Pega o número da generation atual do perfil do sistema
current_gen() {
    nix-env --list-generations --profile /nix/var/nix/profiles/system \
        | tail -1 \
        | awk '{print $1}'
}

# Inicializa o JSON se não existir
init_data() {
    cat > "$DATA_FILE" <<EOF
{
  "meta": {
    "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "description": "NixOS generation tracker - não delete este arquivo!"
  },
  "hosts": {},
  "total": 0
}
EOF
    echo "→ Arquivo de dados criado em: $DATA_FILE"
}

# Garante que jq está disponível
if ! command -v jq &>/dev/null; then
    echo "ERRO: 'jq' não encontrado. Adicione 'jq' ao environment.systemPackages." >&2
    exit 1
fi

# Cria arquivo de dados se não existir
[[ -f "$DATA_FILE" ]] || init_data

GEN_NUMBER=$(current_gen)
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Lê o último generation registrado para este host
LAST_GEN=$(jq -r --arg h "$HOSTNAME" '.hosts[$h].last_generation // 0' "$DATA_FILE")

# Calcula o delta (pode ser 0 se rodou sem mudar generation, ou >1 se pulou)
if [[ "$GEN_NUMBER" -le "$LAST_GEN" ]]; then
    DELTA=0
else
    DELTA=$(( GEN_NUMBER - LAST_GEN ))
fi

# Atualiza o JSON
UPDATED=$(jq \
    --arg h "$HOSTNAME" \
    --argjson gen "$GEN_NUMBER" \
    --argjson delta "$DELTA" \
    --arg now "$NOW" \
    '
    # Inicializa host se necessário
    .hosts[$h] //= {
        "first_seen": $now,
        "generations_count": 0,
        "last_generation": 0,
        "last_rebuild": null
    }
    |
    # Atualiza host
    .hosts[$h].generations_count += $delta
    | .hosts[$h].last_generation = $gen
    | .hosts[$h].last_rebuild = $now
    |
    # Atualiza total global
    .total += $delta
    ' "$DATA_FILE")

echo "$UPDATED" > "$DATA_FILE"

# --- Relatório ---
TOTAL=$(echo "$UPDATED" | jq '.total')
HOST_COUNT=$(echo "$UPDATED" | jq --arg h "$HOSTNAME" '.hosts[$h].generations_count')
HOST_FIRST=$(echo "$UPDATED" | jq -r --arg h "$HOSTNAME" '.hosts[$h].first_seen')

echo ""
echo "┌─────────────────────────────────────────┐"
echo "│         NixOS Generation Tracker         │"
echo "├─────────────────────────────────────────┤"
printf "│  Host:          %-24s │\n" "$HOSTNAME"
printf "│  Generation:    %-24s │\n" "#${GEN_NUMBER}"
printf "│  +Delta:        %-24s │\n" "+${DELTA}"
printf "│  Neste host:    %-24s │\n" "${HOST_COUNT} generations"
printf "│  Primeiro uso:  %-24s │\n" "${HOST_FIRST:0:10}"
echo "├─────────────────────────────────────────┤"
printf "│  ★ TOTAL GLOBAL: %-23s │\n" "${TOTAL} generations"
echo "└─────────────────────────────────────────┘"
echo ""

# Mostra resumo de todos os hosts
echo "Todos os hosts:"
echo "$UPDATED" | jq -r '
    .hosts | to_entries[] |
    "  • \(.key): \(.value.generations_count) generations (última: \(.value.last_rebuild // "nunca"))"
'
echo ""
