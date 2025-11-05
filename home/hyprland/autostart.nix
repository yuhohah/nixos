{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "swww init"
      "vicinae server"
      "numlockx on"
      # "wofi --show drun"  # ← NÃO FAÇA ISSO (abre na inicialização!)
    ];
  };
}