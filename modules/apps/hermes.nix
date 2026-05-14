{ config, ... }: {
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;

    settings.model = {
      provider = "lmstudio";
      # Deixe em branco para auto-detectar o modelo carregado no LM Studio,
      # ou coloque o nome exato: default = "lmstudio/nome-do-seu-modelo";
      default = "lmstudio/auto";
      base_url = "http://localhost:1234/v1";
    };

    environmentFiles = [ "/var/lib/hermes/env" ];
  };
}