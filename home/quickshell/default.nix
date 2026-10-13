{ config, lib, pkgs, osConfig ? {}, ... }:

let
  hostname = osConfig.networking.hostName or "nixos-btw";

  hostShellJson =
    if hostname == "arrow"
    then ./hosts/arrow/shell.json
    else ./hosts/nixos-btw/shell.json;

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
    cp -f ${hostShellJson} $out/shell.json

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
    if pgrep -f "quickshell" > /dev/null 2>&1; then
      pkill -f "quickshell"
    else
      export PATH="$HOME/.config/quickshell/bin:$PATH"
      ${quickshellWrapped}/bin/quickshell &
    fi
  '';
in
{
  imports = [
    ../scripts/desktop-helpers.nix
    ../scripts/agent-usage.nix
  ];

  home.packages = [
    quickshellWrapped
    quickshellToggle
  ];

  xdg.configFile."quickshell" = {
    source = quickshellConfig;
    force = true;
  };
}
