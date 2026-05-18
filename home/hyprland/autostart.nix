{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      #"awww-daemon; wallpaper"
      "vicinae server"
      "mako"
      "hypridle"
      "hyprlock"
      "corectrl --minimize-systray"
    ];
  };
}