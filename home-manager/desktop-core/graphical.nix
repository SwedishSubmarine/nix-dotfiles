{ settings, config, pkgs, theme, unstable, ... }:
let
  XWAYLAND_DISPLAY = ":3";
  random-wallpaper = pkgs.writeScript "random-wallpaper" ''
    #!/bin/sh
    swww img $(find ${../../wallpapers} -type f \( -name '*.png' -o -name '*.jpg' \) | shuf -n 1) --transition-type any --transition-fps 60
  '';
  calendar = pkgs.writeScript "calendar" ''
    ID=$(niri msg -j windows | jq '[.[] | select(.app_id=="firefox") | .id] | last')
    if [ "$ID" != "null" ] ; then
        # firefox is open, switch to it
        niri msg action focus-window --id "$ID"
    fi

    xdg-open "https://calendar.google.com"
  '';
in
{
  imports = [
    ./rofi/rofi.nix
    ./mako.nix
  ];

  # Window manager
  programs.niri.settings = {
    debug.render-drm-device = "/dev/dri/renderD128";
    debug.deactivate-unfocused-windows = [];

    # Input
    cursor = {
      size = 36;
    };
    input = {
      keyboard = {
        xkb = {
          layout = "se";
          variant = "nodeadkeys";
          options = "caps:swapescape";
        };
        repeat-rate = 50;
      };
      touchpad = {
        tap = false;
        click-method = "clickfinger";
        natural-scroll = false;
        dwt = true;
      };
    };

    outputs."eDP-1" = {
      scale = 1.5;
    };

    hotkey-overlay.hide-not-bound = true;
    binds = with config.lib.niri.actions; {
      # Common programs
      "Mod+Shift+T" = {
        hotkey-overlay.title = "Run wezterm";
        action = spawn "wezterm";
      };
      "Mod+Shift+I" = {
        hotkey-overlay.title = "Run firefox";
        action = spawn "firefox";
      };
      "Mod+B" = {
        hotkey-overlay.title = "Run rofi-rbw";
        action = spawn "rofi-rbw";
      };
      "Mod+Shift+B" = {
        hotkey-overlay.title = "Run bitwarden gui";
        action = spawn "bitwarden";
      };

      # Launchers
      "Mod+Space" = {
        hotkey-overlay.title = "rofi launcher";
        action = spawn "rofi" "-modes" "drun" "-show" "drun" "-icon-theme" ''"Papirus"'' "-show-icons";
      };
      "Mod+E" = {
        hotkey-overlay.title = "Web search";
        action = spawn "sh" "${./rofi/web-search.sh}";
      };
      "Mod+Shift+N" = {
        hotkey-overlay.title = "Niri msg";
        action = spawn "sh" "${./rofi/niri-action.sh}";
      };

      # Utility and help
      "Mod+Comma" = {
        hotkey-overlay.title = "Show hotkeys";
        action = show-hotkey-overlay;
      };
      # Credit for this power-menu script https://github.com/jluttine/rofi-power-menu
      "Mod+Escape" = {
        hotkey-overlay.title = "Quit niri";
        action =
          spawn "rofi" "-show" "power-menu" "-show-icons" "-modi"
            "power-menu:${./rofi/rofi-power-menu}";
      };
      "Mod+Q" = {
        hotkey-overlay.title = "Close window";
        action = close-window;
      };

      # Screenshots, screenshot-screen is bronken so doing this until it's fixed
      "Mod+Shift+3" = {
        hotkey-overlay.title = "Screenshot screen";
        action = spawn "niri" "msg" "action" "screenshot-screen";
      };
      "Mod+Shift+4" = {
        hotkey-overlay.title = "Screenshot region";
        action = screenshot;
      };
      "Mod+Shift+5" = {
        hotkey-overlay.title = "Screenshot window";
        action = screenshot-window { write-to-disk = false; };
      };

      # Window and column size
      "Mod+TouchpadScrollRight" = {
        # hotkey-overlay.title = "Expand window";
        hotkey-overlay.hidden = true;
        action = set-window-width "+10";
      };
      "Mod+TouchpadScrollLeft" = {
        # hotkey-overlay.title = "Shrink window";
        hotkey-overlay.hidden = true;
        action = set-window-width "-10";
      };
      "Mod+TouchpadScrollUp" = {
        # hotkey-overlay.title = "Expand window";
        hotkey-overlay.hidden = true;
        action = set-window-height "+10";
      };
      "Mod+TouchpadScrollDown" = {
        # hotkey-overlay.title = "Shrink window";
        hotkey-overlay.hidden = true;
        action = set-window-height "-10";
      };
      "Mod+R" = {
        hotkey-overlay.title = "Switch height";
        action = switch-preset-window-height;
      };
      "Mod+Shift+R" = {
        hotkey-overlay.title = "Reset height";
        action = reset-window-height;
      };
      "Mod+F" = {
        hotkey-overlay.title = "Switch width";
        action = switch-preset-column-width;
      };
      "Mod+Shift+F" = {
        hotkey-overlay.title = "Maximize Column";
        action = maximize-column;
      };
      "Mod+Alt+Shift+F" = {
        hotkey-overlay.title = "Fullscreen";
        action = fullscreen-window;
      };

      #Tabs
      "Mod+T" = {
        hotkey-overlay.title = "Switch to tabbed view";
        action = toggle-column-tabbed-display;
      };
      "Mod+Down" = {
        hotkey-overlay.hidden = true;
        action = focus-window-down;
      };
      "Mod+Up" = {
        hotkey-overlay.hidden = true;
        action = focus-window-up;
      };

      # Window and column movement
      "Mod+Tab" = {
        hotkey-overlay.title = "Focus previous window";
        action = focus-window-previous;
      };
      "Mod+H" = {
        hotkey-overlay.title = "Focus column/window {hjkl}";
        action = focus-column-left;
      };
      "Mod+L" = {
        hotkey-overlay.hidden = true;
        action = focus-column-right;
      };
      "Mod+Ctrl+H" = {
        hotkey-overlay.title = "Move column/window {hjkl}";
        action = move-column-left;
      };
      "Mod+Ctrl+L" = {
        hotkey-overlay.hidden = true;
        action = move-column-right;
      };
      "Mod+V" = {
        hotkey-overlay.title = "Toggle floating windows";
        action = toggle-window-floating;
      };
      "Mod+Shift+V" = {
        hotkey-overlay.title = "Switch tiling/window focus";
        action = switch-focus-between-floating-and-tiling;
      };
      "Mod+Shift+H" = {
        hotkey-overlay.title = "Consume or expel {hl}";
        action = consume-or-expel-window-left;
      };
      "Mod+Shift+L" = {
        hotkey-overlay.hidden = true;
        action = consume-or-expel-window-right;
      };

      # Workspaces
      "Mod+J" = {
        hotkey-overlay.hidden = true;
        action = focus-window-or-workspace-down;
      };
      "Mod+K" = {
        hotkey-overlay.hidden = true;
        action = focus-window-or-workspace-up;
      };
      "Mod+Shift+J" = {
        hotkey-overlay.title = "Focus workspace {jk}";
        action = focus-workspace-down;
      };
      "Mod+Shift+K" = {
        hotkey-overlay.hidden = true;
        action = focus-workspace-up;
      };
      "Mod+Ctrl+J" = {
        hotkey-overlay.title = "Move window or workspace {jk}";
        action = move-window-down-or-to-workspace-down;
      };
      "Mod+Ctrl+K" = {
        # hotkey-overlay.title = "Move window or workspace up";
        hotkey-overlay.hidden = true;
        action = move-window-up-or-to-workspace-up;
      };
      "Mod+O" = {
        hotkey-overlay.title = "Toggle overview";
        action = toggle-overview;
      };
      "Mod+1" = {
        hotkey-overlay.title = "Focus workspace 1";
        action = focus-workspace "firefox";
      };
      "Mod+2" = {
        hotkey-overlay.title = "Focus workspace 2...";
        action = focus-workspace "wezterm";
      };
      "Mod+3" = {
        action = focus-workspace "vesktop";
      };
      "Mod+4" = (if settings.steam then {
        action = focus-workspace "steam";
      } else {
        action = focus-workspace 4;
      });
      "Mod+5" = {
        action = focus-workspace 5;
      };
      "Mod+6" = {
        action = focus-workspace 6;
      };
      "Mod+7" = {
        action = focus-workspace 7;
      };
      "Mod+8" = {
        action = focus-workspace 8;
      };
      "Mod+9" = {
        action = focus-workspace 9;
      };

      # Monitor movement 
      "Mod+Alt+H" = {
        hotkey-overlay.title = "Focus left monitor";
        action = focus-monitor-left;
      };
      "Mod+Alt+L" = {
        hotkey-overlay.title = "Focus right monitor";
        action = focus-monitor-right;
      };
      "Mod+Shift+Tab" = {
        hotkey-overlay.title = "Focus other monitor"; # Assuming two monitors
        action = focus-monitor-previous;
      };
      "Mod+Ctrl+Shift+H" = {
        hotkey-overlay.title = "Move window to left monitor";
        action = move-window-to-monitor-left;
      };
      "Mod+Ctrl+Shift+L" = {
        hotkey-overlay.title = "Move window to right monitor";
        action = move-window-to-monitor-right;
      };
      "Ctrl+Alt+Tab" = {
        hotkey-overlay.title = "Move window to other monitor"; # Assuming two monitors
        action = move-window-to-monitor-previous;
      };

      # Dynamic screen cast
      "Mod+M" = {
        hotkey-overlay.title = "Dynamic cast window";
        action = set-dynamic-cast-window;
      };
      "Mod+Shift+M" = {
        hotkey-overlay.title = "Dynamic cast monitor";
        action = set-dynamic-cast-monitor;
      };
      "Mod+Shift+C" = {
       hotkey-overlay.title = "Clear dynamic cast target";
        action = clear-dynamic-cast-target;
      };

      # Niri switcher
      "Alt+Tab" = { 
        hotkey-overlay.title = "Niriswitcher";
        repeat = false; 
        action = spawn "${pkgs.glib}/bin/gdbus" "call" "--session" "--dest" "io.github.isaksamsten.Niriswitcher" "--object-path" "/io/github/isaksamsten/Niriswitcher" "--method" "io.github.isaksamsten.Niriswitcher.application";
      };

      "Alt+Shift+Tab" = {
        repeat = false;
        action = spawn "${pkgs.glib}/bin/gdbus" "call" "--session" "--dest" "io.github.isaksamsten.Niriswitcher" "--object-path" "/io/github/isaksamsten/Niriswitcher" "--method" "io.github.isaksamsten.Niriswitcher.application"; 
      };

      # Function row
      "XF86MonBrightnessDown".action.spawn = [ "brightnessctl" "s" "10%-"]; 
      "XF86MonBrightnessUp".action.spawn = [ "brightnessctl" "s" "10%+" ];

      "XF86LaunchA".action = toggle-overview;
      
      "XF86Search" = {
        hotkey-overlay.title = "Open calendar";
        action = spawn "sh" "${calendar}";
      };

      "XF86AudioMicMute" = {
        hotkey-overlay.title = "Random wallpaper";
        action = spawn "systemctl" "--user" "start" "wallpaper.service";
      };
      "XF86Sleep".action = spawn "sh" "-c" "niri msg action do-screen-transition && swaylock";

      "XF86AudioPrev".action = spawn "playerctl" "previous";
      "XF86AudioPlay".action = spawn "playerctl" "play-pause";
      "XF86AudioNext".action = spawn "playerctl" "next";

      "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_SINK@" "toggle";
      "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_SINK@" "5%-";
      "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_SINK@" "5%+";
    };

    switch-events = with config.lib.niri.actions; {
      "lid-close" = {
        action = spawn "sh" "-c" "niri msg action do-screen-transition && swaylock";
      };
    };

    spawn-at-startup = [
      { command = [ "${pkgs.xwayland-satellite}/bin/xwayland-satellite" XWAYLAND_DISPLAY ]; }
      # { command = [ "${x-wayland-clipboard-daemon}" ]; }
      { command = [ "${pkgs.dbus}/bin/dbus-update-activation-environment" "--systemd" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP" ]; } # needed for screen-sharing to work
      { command = [ "systemctl" "--user" "start" "background" "nm-applet" ]; }
      { command = [ "swww-daemon" ]; }
      { command = [ "niriswitcher"]; }

      { command = [ "vesktop" "--ozone-platform-hint=wayland" ]; }
      { command = [ "wezterm" ]; }
      { command = [ "firefox" ]; }
    ];
    environment.DISPLAY = XWAYLAND_DISPLAY;

    workspaces = {
      "1" = {
        name = "firefox";
      };
      "2" = {
        name = "wezterm";
      };
      "3" = {
        name = "vesktop";
      };
    };

    prefer-no-csd = true;

    layer-rules = [
      {
        matches = [ { namespace = ''^swww-daemon$''; } ];
        place-within-backdrop = true;
      }
      {
        matches = [ { namespace = "^notifications$"; } ];
        block-out-from = "screencast";
      }
    ];

    window-rules = [
      {
        default-column-width.proportion = 0.5;
        draw-border-with-background = false;
        geometry-corner-radius =
          let
            rad = 10.0;
          in
          {
            bottom-left = rad;
            bottom-right = rad;
            top-right = rad;
            top-left = rad;
          };
        clip-to-geometry = true;
      }
      {
        excludes = [
          { title = ''- YouTube — Mozilla Firefox$''; }
          { title = ''- Twitch — Mozilla Firefox$''; }
          { app-id = ''^darktable$''; }
        ];
      }
      { matches = [ { is-window-cast-target = true; } ];
        focus-ring = {
          active.color = "#f38ba8";
          inactive.color = "#7d0d2d";
        };
        border = {
          enable = true;
          width = 1;
          inactive.color = "#7d0d2d80";
        };
        shadow = {
          color = "#7d0d2d70"; 
        };
      }
      {
        matches = [ { app-id = "org.pulseaudio.pavucontrol"; } ];
        open-floating = true;
        default-window-height.proportion = 0.4;
        default-floating-position = {
          relative-to = "top-right";
          x = 20.0;
          y = 10.0;
        };
      }
      {
        matches = [ { app-id = "blueberry.py"; } ];
        open-floating = true;
        default-window-height.proportion = 0.4;
        default-floating-position = {
          relative-to = "top-right";
          x = 20.0;
          y = 10.0;
        };
      }
      {
        # Sorry alacritty nerds but i dont use this terminal
        matches = [ { app-id = "Alacritty"; } ];
        open-floating = true;
        default-window-height.proportion = 0.3;
        default-column-width.proportion = 0.4;
        focus-ring = {
          width = 2;
          active.color = "#${theme.current.accent2}";
        };
        default-floating-position = {
          relative-to = "top-right";
          x = 20.0;
          y = 10.0;
        };
      }
      {
        matches = [ { app-id = "thunderbird"; } ];
        default-window-height.proportion = 1.0;
        default-column-width.proportion = 1.0;
      }
      {
        matches = [
          {
            app-id = "thunderbird";
            title = "Edit Item";
          }
        ];
        open-floating = true;
        default-window-height.proportion = 0.5;
        default-column-width.proportion = 0.3;
      }
      {
        matches = [
          {
            app-id = "thunderbird";
            title = "Write.*";
          }
        ];
        open-floating = true;
        default-window-height.proportion = 0.9;
        default-column-width.proportion = 0.9;
      }
      {
        matches = [ { app-id = "org.wezfurlong.wezterm"; } ];
        default-window-height.proportion = 1.0;
      }
      {
        matches = [
          {
            app-id = "Bitwarden";
          }
        ];
        open-floating = true;
        default-window-height.proportion = 0.8;
        default-column-width.proportion = 0.5;
      }
      {
        matches = [
          {
            at-startup = true;
            app-id = "firefox";
          }
        ];
        open-on-workspace = "firefox";
        default-column-width.proportion = 1.0;
      }
      {
        matches = [
          {
            at-startup = true;
            app-id = "org.wezfurlong.wezterm";
          }
        ];
        open-on-workspace = "wezterm";
        default-column-width.proportion = 1.0;
      }
      {
        matches = [
          {
            at-startup = true;
            app-id = "vesktop";
          }
        ];
        open-on-workspace = "vesktop";
        default-column-width.proportion = 1.0;
      }
      {
        matches = [ { app-id = "vesktop"; } ];
        opacity = 0.965;
      }
      {
        matches = [ { app-id = "code"; } ];
        opacity = 0.95;
      }
    ];

    overview = {
      workspace-shadow.enable = false;
      zoom = 0.5;
    };

    layout = {
      background-color = "transparent";
      focus-ring = {
        enable = true;
        width = 3;
        active.gradient = {
          from = "#${theme.current.accent2}";
          to = "#${theme.current.accent}";
          angle = 0;
          "in'" = "srgb";
          relative-to = "workspace-view";
        };
        inactive.gradient = {
          from = "#7e83ab"; # Unfortunate
          to = "#896da8"; # Unfortunate
          angle = 0;
          "in'" = "srgb";
          relative-to = "workspace-view";
        };
      };
      shadow = {
        enable = true;
        color = "#00000071";
      };
      tab-indicator = {
        enable = true;
        width = 5.0;
        gap = 4.0;
      };
    };
  } // (if settings.steam then {
    workspaces."4".name = "steam"; 
    window-rules = [
      {
        matches = [ { app-id = "gamescope"; } ];
        open-on-workspace = "steam";
        default-column-width.proportion = 1.0;
        opacity = 1.0;
      }
    ];
  } else {} );

  xdg.configFile."niriswitcher/config.toml".text = ''
    separate_workspaces = false 
  '';
  xdg.configFile."niriswitcher/style.css".text = ''
    .application-title {
      color: #${theme.current.text1};
    }

    :root {
      --bg-color: #${theme.current.base2};
      --border-color: #${theme.current.accent};
    }
  '';

  # Random desktop wallpaper service
  systemd.user.services.wallpaper = {
    Unit = {
      Description = "Random Desktop Wallpaper";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${random-wallpaper}";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.timers.wallpaper = {
    Timer = {
      Unit = "wallpaper";
      OnUnitActiveSec = "1h";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
