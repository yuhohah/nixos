{ config, lib, pkgs, ... }:

let
  cfg = config.my.quickshell;

  internalHelpers = config.desktopHelpers.packages ++ config.agentUsage.packages;

  desktopDeps = [
    pkgs.inotify-tools
    pkgs.libxkbcommon
    pkgs.qrencode
    pkgs.gawk
    pkgs.btop
    pkgs.jq
    pkgs.python3
    pkgs.brightnessctl
  ];

  quickshellConfig = pkgs.runCommand "quickshell-config" {} ''
    mkdir -p $out/bin
    cp -r ${./src}/* $out/
    chmod -R u+w $out
    cp -f ${cfg.configFile} $out/shell.json

    # Injeta os binários utilitários hermeticamente dentro de ~/.config/quickshell/bin
    for pkg in ${lib.concatStringsSep " " internalHelpers}; do
      if [ -d "$pkg/bin" ]; then
        cp -pf "$pkg/bin"/* $out/bin/
      fi
    done
  '';

  quickshellWrapped = pkgs.symlinkJoin {
    name = "quickshell";
    paths = [ pkgs.quickshell ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/quickshell \
        --prefix PATH : ${lib.makeBinPath (internalHelpers ++ desktopDeps)}
    '';
  };

  quickshellToggle = pkgs.writeShellScriptBin "quickshell-toggle" ''
    if pkill -x ".quickshell-wra" 2>/dev/null || pkill -x "quickshell" 2>/dev/null; then
      exit 0
    else
      export PATH="$HOME/.config/quickshell/bin:$PATH"
      nohup ${quickshellWrapped}/bin/quickshell >/dev/null 2>&1 &
    fi
  '';
in
{
  imports = [
    ../scripts/desktop-helpers.nix
    ../scripts/agent-usage.nix
  ];

  options.my.quickshell.configFile = lib.mkOption {
    type = lib.types.path;
    default = ./hosts/nixos-btw/shell.json;
    description = "Path to the host-specific Quickshell shell.json layout.";
  };

  config = {
    home.packages = [
      quickshellWrapped
      quickshellToggle
    ];

    xdg.configFile."quickshell" = {
      source = quickshellConfig;
      force = true;
    };
  };
}
