# ./hyprland/keybinds.nix
{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bind = [
      # Terminal
      "$mod, RETURN, exec, alacritty"

      # Fechar janela
      "$mod, Q, killactive"

      # Launcher
      "$mod, SPACE, exec, vicinae open"

      # Fullscreen
      #"$mod, F, fullscreen, 0"

      # Floating
      "$mod, T, togglefloating"

      # Screenshot
      ", PRINT, exec, screenshot smart"

      # Wallpaper
      "$mod, HOME, exec, wallpaper"

      # Reload
      "$mod, R, exec, hyprctl reload"

      # Exit
      # "$mod SHIFT, E, exec, hyprctl dispatch exit"

      # Lock
      "$mod, L, exec, hyprlock"

      # CONTROLES DE NOTEBOOK
      
      # Volume
      ", XF86AudioRaiseVolume, exec, pamixer -i 5"
      ", XF86AudioLowerVolume, exec, pamixer -d 5"
      ", XF86AudioMute, exec, pamixer -t"
      ", XF86AudioMicMute, exec, pamixer --default-source -t"

      # Brilho
      ", XF86MonBrightnessUp, exec, brightnessctl s +10%"
      ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      
      # Brilho alternativo (Fn+F5/F6 em alguns notebooks)
      ", XF86KbdBrightnessUp, exec, brightnessctl -d *::kbd_backlight set +10%"
      ", XF86KbdBrightnessDown, exec, brightnessctl -d *::kbd_backlight set 10%-"

      # Lock screen (Fn+F10)
      ", XF86ScreenSaver, exec, hyprlock"

    ];

    bindmd = [
      
      # Move/resize windows with mainMod + LMB/RMB
      "$mod, mouse:272, Move window, movewindow"
      "$mod, mouse:273, Resize window, resizewindow"
    ];

    bindd = [
      # Close windows
      "CTRL ALT, DELETE, Close all windows, exec, omarchy-hyprland-window-close-all"

      # Control tiling
      "$mod, J, Toggle window split, togglesplit"
      "$mod, P, Pseudo window, pseudo"

      "$mod, F, Full screen, fullscreen, 0"
      "$mod ALT, F, Full width, fullscreen, 1"

      # Move focus with SUPER + arrow keys
      "$mod, LEFT, Move window focus left, movefocus, l"
      "$mod, RIGHT, Move window focus right, movefocus, r"
      "$mod, UP, Move window focus up, movefocus, u"
      "$mod, DOWN, Move window focus down, movefocus, d"

      # Switch workspaces with SUPER + [1-9]
      "$mod, code:10, Switch to workspace 1, workspace, 1"
      "$mod, code:11, Switch to workspace 2, workspace, 2"
      "$mod, code:12, Switch to workspace 3, workspace, 3"
      "$mod, code:13, Switch to workspace 4, workspace, 4"
      "$mod, code:14, Switch to workspace 5, workspace, 5"
      "$mod, code:15, Switch to workspace 6, workspace, 6"
      "$mod, code:16, Switch to workspace 7, workspace, 7"
      "$mod, code:17, Switch to workspace 8, workspace, 8"
      "$mod, code:18, Switch to workspace 9, workspace, 9"
      "$mod, code:19, Switch to workspace 10, workspace, 10"

      # Move active window to workspace with SUPER + SHIFT + [1-9]
      "$mod SHIFT, code:10, Move window to workspace 1, movetoworkspace, 1"
      "$mod SHIFT, code:11, Move window to workspace 2, movetoworkspace, 2"
      "$mod SHIFT, code:12, Move window to workspace 3, movetoworkspace, 3"
      "$mod SHIFT, code:13, Move window to workspace 4, movetoworkspace, 4"
      "$mod SHIFT, code:14, Move window to workspace 5, movetoworkspace, 5"
      "$mod SHIFT, code:15, Move window to workspace 6, movetoworkspace, 6"
      "$mod SHIFT, code:16, Move window to workspace 7, movetoworkspace, 7"
      "$mod SHIFT, code:17, Move window to workspace 8, movetoworkspace, 8"
      "$mod SHIFT, code:18, Move window to workspace 9, movetoworkspace, 9"

      # Control scratchpad
      #"$mod, S, Toggle scratchpad, togglespecialworkspace, scratchpad"
    
      # TAB between workspaces
      "$mod, TAB, Next workspace, workspace, e+1"

      # Swap active window with neighbour
      "$mod SHIFT, LEFT, Swap window to the left, swapwindow, l"
      "$mod SHIFT, RIGHT, Swap window to the right, swapwindow, r"
      "$mod SHIFT, UP, Swap window up, swapwindow, u"
      "$mod SHIFT, DOWN, Swap window down, swapwindow, d"

      # Cycle through applications on active workspace
      "ALT, TAB, Cycle to next window, cyclenext"

      # Resize active window
      "$mod, code:20, Expand window left, resizeactive, -100 0"
      "$mod, code:21, Shrink window left, resizeactive, 100 0"
      "$mod SHIFT, code:20, Shrink window up, resizeactive, 0 -100"
      "$mod SHIFT, code:21, Expand window down, resizeactive, 0 100"

      # Scroll through workspaces
      "$mod, mouse_down, Scroll active workspace forward, workspace, e+1"
      "$mod, mouse_up, Scroll active workspace backward, workspace, e-1"

      #Apps 
      "$mod, E, File manager, exec, nautilus --new-window"
      "$mod, B, Browser, exec, chromium"
      "$mod SHIFT, B, Browser (private), exec, chromium --incognito"
      "$mod, A, Antigravity, exec, antigravity"
      "$mod, C, VSCODE, exec, code"
      "$mod, code:34, Activity, exec, alacritty -e btop"
      "$mod SHIFT, O, Obsidian, exec, obsidian -disable-gpu"
      "$mod SHIFT, M, Music, exec, spotify"
    ];

    bindl = [
      ", switch:on:Lid Switch, exec, loginctl lock-session"
    ];
  };
}