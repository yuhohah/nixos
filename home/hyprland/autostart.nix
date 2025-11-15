{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "swww init"
      "swww img ~/Pictures/wallpaper/226711.jpg"
      "vicinae server"
      #"numlockx on"
      #"export PATH="$HOME/.local/bin:$PATH""
      "hypridle"
    ];
  };
}