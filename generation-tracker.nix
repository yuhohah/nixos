# generation-tracker.nix
# Módulo NixOS que executa o tracker automaticamente após cada rebuild.
#
# Uso no configuration.nix:
#   imports = [ ./generation-tracker.nix ];
#
# O script track-generation.sh deve estar no mesmo diretório.

{ config, lib, pkgs, ... }:

let
  # Caminho absoluto para o script — ajuste se necessário
  trackerScript = /etc/nixos/track-generation.sh;
in
{
  # Garante que jq esteja disponível (necessário pelo script)
  environment.systemPackages = [ pkgs.jq ];

  # Serviço que roda uma vez após cada boot (e portanto após cada switch)
  systemd.services.nixos-generation-tracker = {
    description = "NixOS Generation Tracker";

    # Roda depois que o sistema estiver completamente pronto
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];

    # Roda apenas uma vez por boot, não reinicia
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash ${trackerScript}";
      # Roda como root para ter acesso ao perfil do sistema
      User = "root";
    };

    # Não falha o boot se o script tiver problema
    unitConfig = {
      FailureAction = "none";
    };
  };
}
