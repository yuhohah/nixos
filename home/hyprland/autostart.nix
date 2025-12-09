{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "swww init; sleep 1; swww-daemon"
      "swww img ~/Pictures/wallpaper/226711.jpg"
      "vicinae server"
      #"numlockx on"
      #"export PATH="$HOME/.local/bin:$PATH""
      "hypridle"
    ];
  };
}