{ pkgs, osConfig ? {}, ... }:

let
  hostname = osConfig.networking.hostName or "nixos-btw";

  # Validação sintática estática de todos os arquivos Lua antes do build/deploy
  validatedLuaDir = pkgs.runCommand "hyprland-lua-validated" {
    nativeBuildInputs = [ pkgs.luajit ];
  } ''
    mkdir -p $out
    cp -r ${./lua}/* $out/

    # luajit -b compila para bytecode em /dev/null, falhando se houver erro de sintaxe
    for f in $out/*.lua; do
      echo "Validando sintaxe de $f..."
      ${pkgs.luajit}/bin/luajit -b "$f" /dev/null
    done
  '';
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    # Delega a execução para o entrypoint Lua modular validado
    extraConfig = ''
      -- Entrypoint do Hyprland Window Manager
      dofile(os.getenv("HOME") .. "/.config/hypr/lua/init.lua")
    '';
  };

  # Árvore de submódulos Lua nativos
  xdg.configFile."hypr/lua".source = validatedLuaDir;

  # Contexto de máquina gerado na seam de deployment
  xdg.configFile."hypr/host.lua".text = ''
    return {
      hostname = "${hostname}"
    }
  '';
}
