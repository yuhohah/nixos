{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "swww init; sleep 1; swww-daemon"
      "swww img ~/Pictures/wallpaper/226711.jpg"
      "vicinae server"
      "hypridle"
      "hyprlock"
    ];
  };
}