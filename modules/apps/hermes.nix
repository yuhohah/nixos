{ config, lib, pkgs, ... }: {
  options.my.apps.hermes.enable = lib.mkEnableOption "Hermes Agent Config";

  config = lib.mkIf config.my.apps.hermes.enable {
    services.hermes-agent = {
      enable = true;
      addToSystemPackages = true;

      extraDependencyGroups = [ "messaging" ];
      
      settings.model = {
        provider = "lmstudio";
        default = "lmstudio/auto";
        base_url = "http://localhost:1234/v1";
        context_length = 8192;
        max_tokens = 1024; 
      };

      environmentFiles = [ "/var/lib/hermes/env" ];
    };
  };
}