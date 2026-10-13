{ pkgs, lib, ... }:

{
  # Systemd user service running OmniRoute as a background gateway
  systemd.user.services.omniroute = {
    Unit = {
      Description = "OmniRoute AI gateway and router";
      After = [ "network.target" "agenix.service" ];
      Wants = [ "agenix.service" ];
    };

    Service = {
      Type = "simple";
      Environment = [
        "NODE_ENV=production"
        "PORT=20128"
        "OMNIROUTE_SERVER_HOST=127.0.0.1"
        "DATA_DIR=%h/.local/share/omniroute"
        "PATH=${lib.makeBinPath [ pkgs.nodejs_24 pkgs.coreutils ]}:%h/.npm-global/bin"
      ];
      # Decrypted env file from agenix (if present)
      EnvironmentFile = "-%t/agenix/omniroute-env";
      WorkingDirectory = "%h/.local/share/omniroute";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/.local/share/omniroute";
      ExecStart = "${pkgs.nodejs_24}/bin/npx -y omniroute@3.8.51 serve --no-open --no-tray";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # OpenCode configuration with OmniRoute provider
  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    provider = {
      omniroute = {
        npm = "@ai-sdk/openai-compatible";
        baseURL = "http://localhost:20128/v1";
        apiKey = "{env:OMNIROUTE_API_KEY}";
        models = {
          "free-combo" = {
            name = "OmniRoute Free Combo";
          };
        };
      };
    };
  };
}
