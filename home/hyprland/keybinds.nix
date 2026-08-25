# ./hyprland/keybinds.nix
{ ... }:
let
  mod = "SUPER";
  terminal = "alacritty";
  fileManager = "nautilus";
  browser = "chromium";
  editor = "code";
  menu = "vicinae open";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    extraConfig = ''
      -- Binds Básicas
      hl.bind("${mod} + RETURN", hl.dsp.exec_cmd("${terminal}"))
      hl.bind("${mod} + Q", hl.dsp.window.close())
      hl.bind("${mod} + SPACE", hl.dsp.exec_cmd("${menu}"))
      hl.bind("${mod} + T", hl.dsp.window.float({ action = "toggle" }))
      hl.bind("PRINT", hl.dsp.exec_cmd("screenshot smart"))
      hl.bind("${mod} + HOME", hl.dsp.exec_cmd("wallpaper"))
      hl.bind("${mod} + R", hl.dsp.exec_cmd("hyprctl reload"))
      hl.bind("${mod} + L", hl.dsp.exec_cmd("hyprlock"))
      
      -- Controles de Notebook
      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { locked = true, repeating = true })
      hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true, repeating = true })
      hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -t"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +10%"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })
      hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set +10%"), { locked = true, repeating = true })
      hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set 10%-"), { locked = true, repeating = true })
      hl.bind("XF86ScreenSaver", hl.dsp.exec_cmd("hyprlock"), { locked = true })

      -- Eventos de Mouse
      hl.bind("${mod} + mouse:272", hl.dsp.window.drag(), { mouse = true })
      hl.bind("${mod} + mouse:273", hl.dsp.window.resize(), { mouse = true })

      -- Binds de Janela e Foco
      hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("omarchy-hyprland-window-close-all"))
      hl.bind("${mod} + P", hl.dsp.window.pseudo())
      hl.bind("${mod} + F", hl.dsp.window.fullscreen({ state = "fullscreen" }))
      hl.bind("${mod} + ALT + F", hl.dsp.window.fullscreen({ state = "maximized" }))
      
      hl.bind("${mod} + LEFT", hl.dsp.focus({ direction = "l" }))
      hl.bind("${mod} + RIGHT", hl.dsp.focus({ direction = "r" }))
      hl.bind("${mod} + UP", hl.dsp.focus({ direction = "u" }))
      hl.bind("${mod} + DOWN", hl.dsp.focus({ direction = "d" }))
      
      -- Switch Workspaces
      for i = 1, 10 do
          local key = i == 10 and 0 or i
          hl.bind("${mod} + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
          hl.bind("${mod} + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
      end
      
      -- Outros Atalhos
      hl.bind("${mod} + TAB", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind("${mod} + SHIFT + LEFT", hl.dsp.window.swap({ direction = "l" }))
      hl.bind("${mod} + SHIFT + RIGHT", hl.dsp.window.swap({ direction = "r" }))
      hl.bind("${mod} + SHIFT + UP", hl.dsp.window.swap({ direction = "u" }))
      hl.bind("${mod} + SHIFT + DOWN", hl.dsp.window.swap({ direction = "d" }))
      
      -- Correção do Cycle Next
      hl.bind("ALT + TAB", hl.dsp.exec_cmd("hyprctl dispatch cyclenext"))
      
      hl.bind("${mod} + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind("${mod} + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
      
      -- Apps 
      hl.bind("${mod} + E", hl.dsp.exec_cmd("${fileManager} --new-window"))
      hl.bind("${mod} + B", hl.dsp.exec_cmd("${browser}"))
      hl.bind("${mod} + SHIFT + B", hl.dsp.exec_cmd("${browser} --incognito"))
      hl.bind("${mod} + A", hl.dsp.exec_cmd("antigravity-ide"))
      hl.bind("${mod} + C", hl.dsp.exec_cmd("${editor}"))
      hl.bind("${mod} + code:34", hl.dsp.exec_cmd("${terminal} -e btop"))
      hl.bind("${mod} + SHIFT + O", hl.dsp.exec_cmd("obsidian -disable-gpu"))
      hl.bind("${mod} + SHIFT + M", hl.dsp.exec_cmd("spotify"))

      -- Evento de tampa (Lid Switch)
      hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("loginctl lock-session"), { locked = true })
    '';
  };
}