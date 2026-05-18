# generation-tracker.nix
# Módulo NixOS — tracker de generations + cemitério de hosts.
#
# Uso no configuration.nix:
#   imports = [ ./generation-tracker.nix ];
#   generationTracker.configDir = "/home/luan/Configuration/nixos";

{ config, lib, pkgs, ... }:

let
  cfg = config.generationTracker;

  trackerScript = pkgs.writeShellScript "track-generation" ''
    set -euo pipefail

    DATA_FILE="${cfg.configDir}/generations.json"
    HOSTNAME="$(${pkgs.hostname}/bin/hostname)"
    JQ="${pkgs.jq}/bin/jq"

    current_gen() {
      ${pkgs.nix}/bin/nix-env --list-generations \
        --profile /nix/var/nix/profiles/system \
        | tail -1 \
        | ${pkgs.gawk}/bin/awk '{print $1}'
    }

    # Data real de instalação do sistema (criação do /etc)
    system_birth() {
      ${pkgs.coreutils}/bin/stat -c '%W' /etc 2>/dev/null || \
      ${pkgs.coreutils}/bin/stat -c '%Y' /etc
    }

    birth_iso() {
      ${pkgs.coreutils}/bin/date -u -d "@$(system_birth)" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || \
      ${pkgs.coreutils}/bin/date -u -r "$(system_birth)" +"%Y-%m-%dT%H:%M:%SZ"
    }

    if [[ ! -f "$DATA_FILE" ]]; then
      cat > "$DATA_FILE" <<EOF
    {
      "meta": {
        "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "description": "NixOS generation tracker - commite este arquivo no git!"
      },
      "hosts": {},
      "graveyard": [],
      "total": 0
    }
    EOF
      echo "→ Arquivo criado em: $DATA_FILE"
    fi

    # Migra JSON antigo que não tem graveyard
    if ! "$JQ" -e '.graveyard' "$DATA_FILE" > /dev/null 2>&1; then
      MIGRATED=$("$JQ" '. + {"graveyard": []}' "$DATA_FILE")
      echo "$MIGRATED" > "$DATA_FILE"
    fi

    GEN_NUMBER=$(current_gen)
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    BIRTH=$(birth_iso)

    LAST_GEN=$("$JQ" -r --arg h "$HOSTNAME" '.hosts[$h].last_generation // 0' "$DATA_FILE")

    if [[ "$GEN_NUMBER" -le "$LAST_GEN" ]]; then
      DELTA=0
    else
      DELTA=$(( GEN_NUMBER - LAST_GEN ))
    fi

    # Se é um host novo (não existe no JSON), inicializa com a data real de criação
    IS_NEW=$("$JQ" -r --arg h "$HOSTNAME" '.hosts[$h] == null' "$DATA_FILE")

    UPDATED=$("$JQ" \
      --arg h "$HOSTNAME" \
      --argjson gen "$GEN_NUMBER" \
      --argjson delta "$DELTA" \
      --arg now "$NOW" \
      --arg birth "$BIRTH" \
      --argjson is_new "$IS_NEW" \
      '
      .hosts[$h] //= {
        "born_at": $birth,
        "generations_count": 0,
        "last_generation": 0,
        "last_rebuild": null
      }
      | if $is_new then .hosts[$h].born_at = $birth else . end
      | .hosts[$h].generations_count += $delta
      | .hosts[$h].last_generation = $gen
      | .hosts[$h].last_rebuild = $now
      | .total += $delta
      ' "$DATA_FILE")

    echo "$UPDATED" > "$DATA_FILE"

    TOTAL=$(echo "$UPDATED" | "$JQ" '.total')
    HOST_COUNT=$(echo "$UPDATED" | "$JQ" --arg h "$HOSTNAME" '.hosts[$h].generations_count')
    HOST_BIRTH=$(echo "$UPDATED" | "$JQ" -r --arg h "$HOSTNAME" '.hosts[$h].born_at')
    GRAVEYARD_COUNT=$(echo "$UPDATED" | "$JQ" '.graveyard | length')

    echo ""
    echo "┌─────────────────────────────────────────┐"
    echo "│         NixOS Generation Tracker         │"
    echo "├─────────────────────────────────────────┤"
    printf "│  Host:          %-24s │\n" "$HOSTNAME"
    printf "│  Nascido em:    %-24s │\n" "''${HOST_BIRTH:0:10}"
    printf "│  Generation:    %-24s │\n" "#''${GEN_NUMBER}"
    printf "│  +Delta:        %-24s │\n" "+''${DELTA}"
    printf "│  Neste host:    %-24s │\n" "''${HOST_COUNT} generations"
    echo "├─────────────────────────────────────────┤"
    printf "│  ★ TOTAL GLOBAL: %-23s │\n" "''${TOTAL} generations"
    printf "│  Hosts vivos:   %-24s │\n" "$(echo "$UPDATED" | "$JQ" '.hosts | length')"
    printf "│  Hosts mortos:  %-24s │\n" "''${GRAVEYARD_COUNT}"
    echo "└─────────────────────────────────────────┘"
    echo ""

    # Hosts vivos
    echo "Hosts ativos:"
    echo "$UPDATED" | "$JQ" -r '
      .hosts | to_entries[] |
      "  ● \(.key)  |  nascido: \(.value.born_at[:10])  |  \(.value.generations_count) generations"
    '

    # Cemitério
    if [[ "$GRAVEYARD_COUNT" -gt 0 ]]; then
      echo ""
      echo "Cemitério:"
      echo "$UPDATED" | "$JQ" -r '
        .graveyard[] |
        "  ✝ \(.name)  |  \(.born_at[:10]) → \(.died_at[:10])  |  \(.generations_count) generations"
      '
    fi
    echo ""
  '';

  # Script separado para aposentar um host manualmente antes de formatar
  retireScript = pkgs.writeShellScript "retire-host" ''
    set -euo pipefail

    DATA_FILE="${cfg.configDir}/generations.json"
    JQ="${pkgs.jq}/bin/jq"
    HOSTNAME="$(${pkgs.hostname}/bin/hostname)"
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    if [[ ! -f "$DATA_FILE" ]]; then
      echo "ERRO: $DATA_FILE não encontrado." >&2
      exit 1
    fi

    EXISTS=$("$JQ" -r --arg h "$HOSTNAME" '.hosts[$h] != null' "$DATA_FILE")
    if [[ "$EXISTS" != "true" ]]; then
      echo "ERRO: host '$HOSTNAME' não encontrado no JSON." >&2
      exit 1
    fi

    UPDATED=$("$JQ" \
      --arg h "$HOSTNAME" \
      --arg now "$NOW" \
      '
      .graveyard += [{
        "name": $h,
        "born_at": .hosts[$h].born_at,
        "died_at": $now,
        "generations_count": .hosts[$h].generations_count,
        "last_generation": .hosts[$h].last_generation
      }]
      | del(.hosts[$h])
      ' "$DATA_FILE")

    echo "$UPDATED" > "$DATA_FILE"
    echo "✝ Host '$HOSTNAME' aposentado e movido para o cemitério."
    echo "  Pode formatar agora. O histórico está salvo em $DATA_FILE"
  '';
in
{
  options.generationTracker = {
    configDir = lib.mkOption {
      type = lib.types.str;
      description = ''
        Caminho para o diretório do repositório git com as configurações NixOS.
        O generations.json será salvo diretamente aqui.
        Exemplo: "/home/luan/Configuration/nixos"
      '';
    };
  };

  config = {
    system.activationScripts.generationTracker = {
      supportsDryActivation = false;
      text = ''
        ${trackerScript} || true
      '';
    };

    # Disponibiliza o comando retire-host no sistema
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "retire-host" ''
        exec ${retireScript} "$@"
      '')
    ];
  };
}
