{ ... }:

{
  wayland.windowManager.hyprland = {
    # Garante que este módulo também sabe que o alvo é Lua
    configType = "lua";

    extraConfig = ''
      -- Comandos de autostart (mako e hypridle são gerenciados via systemd)
      hl.on("hyprland.start", function()
        hl.exec_cmd("awww-daemon")
        hl.exec_cmd("hyprlock")
        hl.exec_cmd("corectrl --minimize-systray")
        hl.exec_cmd("quickshell")
      end)
    '';
  };
}