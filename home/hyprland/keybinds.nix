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
      ", PRINT, exec, /home/luan/.local/bin/screenshot smart"           # Print = screenshot inteligente com editor
      "SHIFT, PRINT, exec, /home/luan/.local/bin/screenshot region"     # Shift+Print = selecionar região
      "CTRL, PRINT, exec, /home/luan/.local/bin/screenshot fullscreen"  # Ctrl+Print = tela cheia
      "ALT, PRINT, exec, /home/luan/.local/bin/screenshot windows"      # Alt+Print = selecionar janela

      #Change Wallpaper
      "$mod, HOME, exec, /home/luan/.local/bin/wallpaper"

      # Reload
      "$mod, R, exec, hyprctl reload"

      # Sair
      "$mod SHIFT, E, exec, hyprctl dispatch exit"

      # Volume (pamixer)
      ", XF86AudioRaiseVolume, exec, pamixer -i 5"
      ", XF86AudioLowerVolume, exec, pamixer -d 5"
      ", XF86AudioMute, exec, pamixer -t"

      # Brilho
      ", XF86MonBrightnessUp, exec, brightnessctl s +10%"
      ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"

      # Lock
      "$mod, L, exec, swaylock"
    ];

    bindmd = [
      
      # Move/resize windows with mainMod + LMB/RMB
      "$mod, mouse:272, Move window, movewindow"
      "$mod, mouse:273, Resize window, resizewindow"
    ];

    # ----------------------------------------------------------
    #  NOVAS KEYBINDINGS (com descrição via bindd)
    # ----------------------------------------------------------
    bindd = [
      # Close windows
      "CTRL ALT, DELETE, Close all windows, exec, omarchy-hyprland-window-close-all"

      # Control tiling
      "$mod, J, Toggle window split, togglesplit"
      "$mod, P, Pseudo window, pseudo"

      #"$mod, T, Toggle window floating/tiling, togglefloating"
      "$mod, F, Full screen, fullscreen, 0"
      "$mod CTRL, F, Tiled full screen, fullscreenstate, 0 2"
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
      "$mod SHIFT, TAB, Previous workspace, workspace, e-1"
      "$mod CTRL, TAB, Former workspace, workspace, previous"

      # Swap active window with neighbour
      "$mod SHIFT, LEFT, Swap window to the left, swapwindow, l"
      "$mod SHIFT, RIGHT, Swap window to the right, swapwindow, r"
      "$mod SHIFT, UP, Swap window up, swapwindow, u"
      "$mod SHIFT, DOWN, Swap window down, swapwindow, d"

      # Cycle through applications on active workspace
      "ALT, TAB, Cycle to next window, cyclenext"
      "ALT SHIFT, TAB, Cycle to prev window, cyclenext, prev"
      "ALT, TAB, Reveal active window on top, bringactivetotop"
      "ALT SHIFT, TAB, Reveal active window on top, bringactivetotop"

      # Resize active window
      "$mod, code:20, Expand window left, resizeactive, -100 0"
      "$mod, code:21, Shrink window left, resizeactive, 100 0"
      "$mod SHIFT, code:20, Shrink window up, resizeactive, 0 -100"
      "$mod SHIFT, code:21, Expand window down, resizeactive, 0 100"

      # Scroll through workspaces
      "$mod, mouse_down, Scroll active workspace forward, workspace, e+1"
      "$mod, mouse_up, Scroll active workspace backward, workspace, e-1"

      # Toggle groups
      "$mod, G, Toggle window grouping, togglegroup"
      "$mod ALT, G, Move active window out of group, moveoutofgroup"

      # Join groups
      "$mod ALT, LEFT, Move window to group on left, moveintogroup, l"
      "$mod ALT, RIGHT, Move window to group on right, moveintogroup, r"
      "$mod ALT, UP, Move window to group on top, moveintogroup, u"
      "$mod ALT, DOWN, Move window to group on bottom, moveintogroup, d"

      # Navigate grouped windows
      "$mod ALT, TAB, Next window in group, changegroupactive, f"
      "$mod ALT SHIFT, TAB, Previous window in group, changegroupactive, b"
      "$mod ALT, mouse_down, Next window in group, changegroupactive, f"
      "$mod ALT, mouse_up, Previous window in group, changegroupactive, b"

      # Activate group window by number
      "$mod ALT, 1, Switch to group window 1, changegroupactive, 1"
      "$mod ALT, 2, Switch to group window 2, changegroupactive, 2"
      "$mod ALT, 3, Switch to group window 3, changegroupactive, 3"
      "$mod ALT, 4, Switch to group window 4, changegroupactive, 4"
      "$mod ALT, 5, Switch to group window 5, changegroupactive, 5"

      #Apps 
      "$mod, E, File manager, exec, -- nautilus --new-window"
      "$mod, B, Browser, exec, chromium"
      "$mod SHIFT, B, Browser (private), exec, chromium --private"
      "$mod, code:34, Activity, exec, alacritty -e btop"
      "$mod SHIFT, O, Obsidian, exec, obsidian -disable-gpu"
      "$mod SHIFT, M, Music, exec, spotify"
    ];
  };
}