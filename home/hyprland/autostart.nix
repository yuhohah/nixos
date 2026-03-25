{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "swww init; sleep 1; swww-daemon"
      "swww img ~/Pictures/wallpaper/226711.jpg"
      "vicinae server"
      "mako"
      "hypridle"
      "hyprlock"
    ];
  };
}