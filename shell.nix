{ pkgs ? import <nixpkgs> { overlays = [ (import ./overlays/ai-tools.nix) ]; } }:

let
  t3 = pkgs.callPackage ./home/t3code/package.nix { };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs_24
    opencode
    t3
    curl
  ];

  # Prebuilt native addons (better-sqlite3, node-pty, sharp...) need libstdc++
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ];

  shellHook = ''
    echo "🤖 AI Environment ready:"
    echo "   • Node: $(node -v) | OpenCode: $(opencode --version 2>/dev/null)"
    echo "   • Commands available: 't3', 'opencode'"
  '';
}
