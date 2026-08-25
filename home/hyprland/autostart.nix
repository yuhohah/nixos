{ ... }:

{
  wayland.windowManager.hyprland = {
    # Garante que este módulo também sabe que o alvo é Lua
    configType = "lua";

    extraConfig = ''
      -- Coloca os comandos de autostart no evento correto de inicialização
      hl.on("hyprland.start", function()
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
        hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
        hl.exec_cmd("awww-daemon")
        hl.exec_cmd("vicinae server")
        hl.exec_cmd("mako")
        hl.exec_cmd("hypridle")
        hl.exec_cmd("hyprlock")
        hl.exec_cmd("corectrl --minimize-systray")
      end)
    '';
  };
}