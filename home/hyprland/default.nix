{ config, lib, pkgs, ... }:

let
  cfg = config.my.hyprland;
  luaStr = s: builtins.toJSON s;

  renderMonitor = m:
    "    { output = ${luaStr m.output}, mode = ${luaStr m.mode}, position = ${luaStr m.position}, scale = ${luaStr m.scale} },";

  renderWorkspace = w:
    "    { workspace = ${luaStr w.workspace}, monitor = ${luaStr w.monitor} },";

  hostLuaText = ''
    return {
      keyboard = {
        layout = ${luaStr cfg.keyboard.layout},
        variant = ${luaStr cfg.keyboard.variant},
      },
      autostart = {
    ${lib.concatMapStringsSep "\n" (cmd: "    ${luaStr cmd},") cfg.autostart}
      },
      monitors = {
    ${lib.concatMapStringsSep "\n" renderMonitor cfg.monitors}
      },
      workspaces = {
    ${lib.concatMapStringsSep "\n" renderWorkspace cfg.workspaces}
      },
    }
  '';

  validatedHostLua = pkgs.runCommand "hyprland-host-lua-validated" {
    nativeBuildInputs = [ pkgs.luajit ];
  } ''
    cp ${pkgs.writeText "host.lua" hostLuaText} $out
    ${pkgs.luajit}/bin/luajit -b "$out" /dev/null
  '';

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
  options.my.hyprland = {
    keyboard = {
      layout = lib.mkOption {
        type = lib.types.str;
        default = "us";
        description = "XKB keyboard layout(s) for Hyprland.";
      };
      variant = lib.mkOption {
        type = lib.types.str;
        default = "intl";
        description = "XKB keyboard variant(s) for Hyprland.";
      };
    };

    autostart = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra commands started on hyprland.start (in addition to core daemons).";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          output = lib.mkOption { type = lib.types.str; };
          mode = lib.mkOption { type = lib.types.str; };
          position = lib.mkOption { type = lib.types.str; default = "auto"; };
          scale = lib.mkOption { type = lib.types.str; default = "1"; };
        };
      });
      default = [ ];
      description = "Declarative Hyprland monitor definitions.";
    };

    workspaces = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          workspace = lib.mkOption { type = lib.types.str; };
          monitor = lib.mkOption { type = lib.types.str; };
        };
      });
      default = [ ];
      description = "Declarative Hyprland workspace-to-monitor bindings.";
    };
  };

  config = {
    wayland.windowManager.hyprland = {
      enable = true;
      # A sessão systemd é gerenciada pelo UWSM (programs.hyprland.withUWSM = true)
      systemd.enable = false;
      configType = "lua";

      # Delega a execução para o entrypoint Lua modular validado
      extraConfig = ''
        -- Entrypoint do Hyprland Window Manager
        dofile(os.getenv("HOME") .. "/.config/hypr/lua/init.lua")
      '';
    };

    # Árvore de submódulos Lua nativos
    xdg.configFile."hypr/lua".source = validatedLuaDir;

    # Contexto declarativo de máquina gerado e validado no build
    xdg.configFile."hypr/host.lua".source = validatedHostLua;
  };
}
