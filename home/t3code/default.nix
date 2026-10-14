{ pkgs, lib, ... }:

let
  t3Pkg = pkgs.t3code.override { enableOpencode = true; };

  t3Runner = pkgs.writeShellScript "t3code-start" ''
    if [ -n "$XDG_RUNTIME_DIR" ] && [ -r "$XDG_RUNTIME_DIR/agenix/omniroute-api-key" ]; then
      export OMNIROUTE_API_KEY="$(cat "$XDG_RUNTIME_DIR/agenix/omniroute-api-key")"
    fi
    exec ${t3Pkg}/bin/t3 --no-browser --port 3773
  '';
in
{
  home.packages = [ t3Pkg ];

  # Systemd user service running T3 Code as a background server
  systemd.user.services.t3code = {
    Unit = {
      Description = "T3 Code Web Server";
      After = [ "network.target" "agenix.service" "omniroute.service" ];
      Wants = [ "omniroute.service" ];
    };

    Service = {
      Type = "simple";
      Environment = [
        "NODE_ENV=production"
        "PATH=/run/current-system/sw/bin:${lib.makeBinPath [ pkgs.nodejs_24 pkgs.coreutils pkgs.git pkgs.openssh pkgs.curl ]}:%h/.local/bin:%h/.npm-global/bin"
      ];
      EnvironmentFile = "-%t/agenix/omniroute-env";
      WorkingDirectory = "%h";
      ExecStart = "${t3Runner}";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
