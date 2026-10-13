{ pkgs ? import <nixpkgs> { } }:

let
  # Path where the agenix Home Manager module decrypts the OmniRoute key
  omnirouteKeyFile = "\${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/agenix/omniroute-api-key";

  # T3 Code launcher (web mode: most reliable on NixOS without AppImage / FHS issues)
  t3 = pkgs.writeShellScriptBin "t3" ''
    exec ${pkgs.nodejs_24}/bin/npx -y t3@latest "$@"
  '';

  # OmniRoute CLI helper
  omniroute = pkgs.writeShellScriptBin "omniroute" ''
    exec ${pkgs.nodejs_24}/bin/npx -y omniroute@3.8.51 "$@"
  '';
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs_24 # OmniRoute requires node >=22.22 <23 or >=24 <27
    opencode
    t3
    omniroute
    curl
  ];

  # Prebuilt native addons (better-sqlite3, node-pty, sharp...) need libstdc++
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ];

  shellHook = ''
    key_file="${omnirouteKeyFile}"
    if [ -r "$key_file" ]; then
      export OMNIROUTE_API_KEY="$(cat "$key_file")"
    else
      echo "⚠️  OmniRoute key not found at $key_file."
      echo "   (It will be automatically decrypted once you apply the agenix module and switch)."
    fi

    if ${pkgs.curl}/bin/curl -fsS -o /dev/null --max-time 2 http://localhost:20128; then
      omni_status="UP (http://localhost:20128)"
    else
      omni_status="DOWN (systemctl --user status omniroute)"
    fi

    echo "🤖 AI Environment ready:"
    echo "   • Node: $(node -v) | OpenCode: $(opencode --version 2>/dev/null)"
    echo "   • OmniRoute: $omni_status"
    echo "   • Commands available: 't3', 'omniroute', 'opencode'"
  '';
}
