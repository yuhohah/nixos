{ config, lib, pkgs, ... }:

let
  cfg = config.my.system.greetd;
  luaStr = s: builtins.toJSON s;

  hmHyprland =
    if (config.home-manager.users ? ${cfg.user}) && (config.home-manager.users.${cfg.user} ? my)
    then config.home-manager.users.${cfg.user}.my.hyprland
    else {
      keyboard = { layout = "us"; variant = "intl"; };
      monitors = [ ];
    };

  sessionCmd = [
    "${pkgs.uwsm}/bin/uwsm"
    "start"
    "-e"
    "-D"
    "Hyprland"
    "hyprland.desktop"
  ];

  greeterConfigQml = pkgs.writeText "GreeterConfig.qml" ''
    pragma Singleton
    import QtQuick

    QtObject {
      readonly property string user: ${builtins.toJSON cfg.user}
      readonly property string backgroundPath: ${builtins.toJSON "file://${cfg.background}"}
      readonly property string avatarPath: ${builtins.toJSON "file://${cfg.avatar}"}
      readonly property var sessionCommand: ${builtins.toJSON sessionCmd}
    }
  '';

  greeterQmldir = pkgs.writeText "qmldir" ''
    singleton GreeterConfig 1.0 GreeterConfig.qml
  '';

  greeterQmlDir = pkgs.runCommand "quickshell-greetd-greeter" { } ''
    mkdir -p $out
    cp ${./greetd-greeter/shell.qml} $out/shell.qml
    cp ${greeterConfigQml} $out/GreeterConfig.qml
    cp ${greeterQmldir} $out/qmldir
  '';

  greeterLauncher = pkgs.writeShellScript "quickshell-greeter-launch" ''
    export PATH="${lib.makeBinPath [ pkgs.bash pkgs.coreutils ]}:/run/current-system/sw/bin"
    ${pkgs.quickshell}/bin/quickshell --no-color -p ${greeterQmlDir}
    ${pkgs.hyprland}/bin/hyprctl dispatch exit >/dev/null 2>&1 || true
  '';

  renderMonitor = m:
    "hl.monitor({ output = ${luaStr m.output}, mode = ${luaStr m.mode}, position = ${luaStr m.position}, scale = ${luaStr m.scale} })";

  greeterHyprlandLuaText = ''
    hl.config({
      misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        background_color = "rgb(1e1e2e)",
      },
      animations = {
        enabled = false,
      },
      input = {
        kb_layout = ${luaStr cfg.keyboard.layout},
        kb_variant = ${luaStr cfg.keyboard.variant},
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        touchpad = {
          natural_scroll = true,
        },
      },
      cursor = {
        inactive_timeout = 1,
        hide_on_key_press = true,
      },
    })

    ${lib.concatMapStringsSep "\n" renderMonitor cfg.monitors}

    hl.on("hyprland.start", function()
      hl.exec_cmd(${luaStr "${greeterLauncher}"})
    end)
  '';

  # Validação sintática estática da config Lua do compositor do greeter no build
  greeterHyprlandConfig = pkgs.runCommand "greeter-hyprland.lua" {
    nativeBuildInputs = [ pkgs.luajit ];
  } ''
    cp ${pkgs.writeText "greeter-hyprland-raw.lua" greeterHyprlandLuaText} $out
    ${pkgs.luajit}/bin/luajit -b "$out" /dev/null
  '';

  greeterSession = pkgs.writeShellScript "quickshell-greeter-session" ''
    set -u
    runtime_dir="''${XDG_RUNTIME_DIR:-/tmp/greeter-$UID}"
    mkdir -p "$runtime_dir/greeter-home" "$runtime_dir/greeter-cache" "$runtime_dir/greeter-config" "$runtime_dir/greeter-state"
    export HOME="$runtime_dir/greeter-home"
    export XDG_CACHE_HOME="$runtime_dir/greeter-cache"
    export XDG_CONFIG_HOME="$runtime_dir/greeter-config"
    export XDG_STATE_HOME="$runtime_dir/greeter-state"
    export LANG="pt_BR.UTF-8"
    export XDG_SESSION_TYPE="wayland"
    export QT_QPA_PLATFORM="wayland"
    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    unset QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE
    exec ${pkgs.hyprland}/bin/Hyprland --config ${greeterHyprlandConfig}
  '';
in
{
  options.my.system.greetd = {
    enable = lib.mkEnableOption "Greetd Config";
    user = lib.mkOption {
      type = lib.types.str;
      default = "luan";
      description = "Default login user pre-selected by the Quickshell greeter.";
    };
    background = lib.mkOption {
      type = lib.types.path;
      default = ../../images/wallpaper/1119050.jpg;
      description = "Wallpaper path rendered with blur on the login greeter.";
    };
    avatar = lib.mkOption {
      type = lib.types.path;
      default = ../../images/profile/profile.jpg;
      description = "Circular profile picture displayed on the login greeter.";
    };
    keyboard = {
      layout = lib.mkOption {
        type = lib.types.str;
        default = hmHyprland.keyboard.layout;
        description = "XKB keyboard layout(s) used on the login screen.";
      };
      variant = lib.mkOption {
        type = lib.types.str;
        default = hmHyprland.keyboard.variant;
        description = "XKB keyboard variant(s) used on the login screen.";
      };
    };
    monitors = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.str);
      default = hmHyprland.monitors;
      description = "Monitor rules applied in the isolated greeter Hyprland session.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${greeterSession}";
          user = "greeter";
        };
      };
    };

    environment.sessionVariables = {
      GTK_THEME = "Adwaita-dark";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_STYLE_OVERRIDE = "adwaita-dark";
    };
  };
}
