{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host.hyprland;

  inherit (lib.generators) mkLuaInline;
  toLua' = lib.generators.toLua {multiline = false;};

  # Lua helpers for the HM `settings` DSL (see wayland.windowManager.hyprland.settings).
  # `dsp "window.move" [{ workspace = 3; }]` -> hl.dsp.window.move({ ["workspace"] = 3 })
  dsp = name: args: mkLuaInline "hl.dsp.${name}(${lib.concatMapStringsSep ", " toLua' args})";
  exec = cmd: dsp "exec_cmd" [cmd];
  # Several dispatchers on one key: wrap them in a function that runs each in order.
  dspSeq = dispatchers:
    mkLuaInline "function()\n${lib.concatMapStrings (d: "  hl.dispatch(${d.expr})\n") dispatchers}end";

  # `bind "SUPER + d" (exec "rofi")` -> hl.bind("SUPER + d", hl.dsp.exec_cmd("rofi"))
  bind = keys: dispatcher: {_args = [keys dispatcher];};
  bindWith = opts: keys: dispatcher: {_args = [keys dispatcher opts];};

  # Workspace -> monitor distribution: same logic as i3/common.nix.
  numMonitors = builtins.length cfg.monitors;
  workspaceGroups =
    if numMonitors > 1
    then [
      ((lib.range 1 5) ++ (lib.range 11 15))
      ((lib.range 6 10) ++ (lib.range 16 20))
    ]
    else [(lib.range 1 20)];

  # Pre-assign each workspace to a monitor so it spawns there on first use.
  workspaceRules = lib.flatten (
    lib.zipListsWith
    (monitor: ids:
      map (id: {
        workspace = toString id;
        monitor = monitor.name;
      })
      ids)
    cfg.monitors
    workspaceGroups
  );

  monitorRules =
    map (m:
      {
        output = m.name;
        inherit (m) mode position scale transform;
        disabled = !m.enabled;
      }
      // lib.optionalAttrs (m.bitdepth != null) {inherit (m) bitdepth;}
      // m.extraSettings)
    cfg.monitors
    # Catch-all for anything not declared above.
    ++ [
      {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = 1;
      }
    ];

  # Workspace number-key bindings:
  # SUPER+n: 1..10, ALT+n: 11..20 (key 0 -> 10/20)
  numKeyBinds = lib.concatMap (n: let
    key = toString (lib.mod n 10);
    altWs = n + 10;
  in [
    (bind "SUPER + ${key}" (dsp "focus" [{workspace = n;}]))
    (bind "SUPER + SHIFT + ${key}" (dsp "window.move" [{workspace = n;}]))
    (bind "ALT + ${key}" (dsp "focus" [{workspace = altWs;}]))
    (bind "ALT + SHIFT + ${key}" (dsp "window.move" [{workspace = altWs;}]))
  ]) (lib.range 1 10);

  sessionEnv = {
    XCURSOR_THEME = "Fuchsia-Pop"; # TODO
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Fuchsia-Pop";
    HYPRCURSOR_SIZE = "24";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    GDK_BACKEND = "wayland,x11";
    # Extra
    _GL_GSYNC_ALLOWED = "1";
    LIBVA_DRIVER_NAME = "nvidia"; # TODO
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NVD_BACKEND = "direct";
  };
in {
  # https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager/#nixos-uwsm
  xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  wayland.windowManager.hyprland = {
    enable = true;
    # Breaks things
    # package = pkgs.stable.hyprland;

    # Set in modules/nixos/base/services.nix
    portalPackage = null;

    configType = "lua";

    # For uwsm
    systemd.enable = false;
    xwayland.enable = true;

    # pywal palette with defaults
    extraLuaFiles.wal = ''
      local fallback = { color1 = "rgb(cccccc)", color8 = "rgb(595959)" }
      local ok, palette = pcall(dofile, "${config.xdg.cacheHome}/wal/colors-hyprland.lua")
      if not ok or type(palette) ~= "table" then
        return fallback
      end
      return setmetatable(palette, { __index = fallback })
    '';

    settings = {
      # local wal = require("wal")
      wal._var = mkLuaInline ''require("wal")'';

      monitor = monitorRules;

      workspace_rule = workspaceRules;

      config = {
        general = {
          gaps_in = 12;
          gaps_out = 0;
          border_size = 2;
          layout = "dwindle";
          col = {
            active_border = mkLuaInline "wal.color1";
            inactive_border = mkLuaInline "wal.color8";
          };
          allow_tearing = false;
        };

        decoration = {
          rounding = 0;
          shadow.enabled = false;
          blur.enabled = false;
          active_opacity = 1.0;
          inactive_opacity = 1.0;
        };

        dwindle = {
          preserve_split = true;
          # 0 = follow mouse, 1 = always to the left, 2 = always to the right.
          # 2 mimics i3-layouts autosplit's "new on the right" behavior.
          force_split = 2;
        };

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          accel_profile = "adaptive";
          touchpad = {
            natural_scroll = true;
            middle_button_emulation = true;
            disable_while_typing = false;
          };
        };

        gestures = {
          workspace_swipe_create_new = true;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          focus_on_activate = false;
          initial_workspace_tracking = 2;
        };

        render = {
          # Don't flip the output into HDR when a fullscreen client asks for it.
          # TODO: might flip this maybe. Right now it blacks out the screen for a second
          # or two on chromium
          cm_auto_hdr = false;
        };
      };

      animation = {
        leaf = "global";
        enabled = true;
        speed = 1;
        bezier = "default";
      };

      gesture = {
        fingers = 3;
        direction = "horizontal";
        action = "workspace";
      };

      # XWayland cursor sizing + Wayland-app conformance.
      env = lib.mapAttrsToList (name: value: {_args = [name value];}) sessionEnv;

      # # Window rules for scratchpad and stuff
      # window_rule = [
      #   # Picture-in-Picture: float + sticky.
      #   { match.title = "^(Picture-in-Picture)$"; float = true; pin = true; }
      #   # 1Password Lock Screen: float + sticky + 800x800.
      #   { match = { class = "^(1Password)$"; title = ".*Lock Screen.*"; }; float = true; pin = true; size = "800 800"; }
      #   # Sharing Indicator: float + sticky.
      #   { match.title = ".*Sharing Indicator.*"; float = true; pin = true; }
      #   # Plexamp: float.
      #   { match.title = "^(Plexamp)$"; float = true; }
      #   # feh: float (parity with the i3 rule).
      #   { match.class = "^(feh)$"; float = true; }
      # ];

      bind =
        [
          # Application launchers
          (bind "SUPER + Return" (exec config.host.terminal.cmd.spawn))
          (bind "SUPER + d" (exec config.host.launcher.cmd.launcher))
          (bind "SUPER + SHIFT + d" (exec config.host.launcher.cmd.windows))

          # fd + rofi pipelines
          (bind "ALT + d" (exec config.host.launcher.cmd.fd))
          (bind "ALT + SHIFT + d" (exec config.host.launcher.cmd.fdDirs))

          # Focus
          (bind "SUPER + left" (dsp "focus" [{direction = "left";}]))
          (bind "SUPER + down" (dsp "focus" [{direction = "down";}]))
          (bind "SUPER + up" (dsp "focus" [{direction = "up";}]))
          (bind "SUPER + right" (dsp "focus" [{direction = "right";}]))

          # Move
          (bind "SUPER + SHIFT + left" (dsp "window.move" [{direction = "left";}]))
          (bind "SUPER + SHIFT + down" (dsp "window.move" [{direction = "down";}]))
          (bind "SUPER + SHIFT + up" (dsp "window.move" [{direction = "up";}]))
          (bind "SUPER + SHIFT + right" (dsp "window.move" [{direction = "right";}]))

          # Resize (defined in submap below)
          (bind "SUPER + r" (dsp "submap" ["resize"]))

          # Workspace cycling
          (bind "SUPER + comma" (dsp "focus" [{workspace = "e-1";}]))
          (bind "SUPER + period" (dsp "focus" [{workspace = "e+1";}]))
          (bind "ALT + Tab" (dsp "focus" [{workspace = "e+1";}]))
          (bind "SUPER + Tab" (dsp "focus" [{workspace = "e-1";}]))

          # Misc
          (bind "SUPER + x" (exec config.host.lock.command))
          (bind "SUPER + Print" (exec config.host.screenshot.command))
          (bind "SUPER + SHIFT + Insert" (exec config.host.screenshot.command))
          (bind "CTRL + grave" (exec config.host.notifications.historyCommand))

          # Window control
          (bind "SUPER + SHIFT + q" (dsp "window.close" []))
          (bind "SUPER + f" (dsp "window.fullscreen" [{mode = "fullscreen";}]))
          (bind "SUPER + SHIFT + space" (dsp "window.float" []))

          # Scratchpad (i3-like): force floating, then move silently to the special workspace.
          (bind "SUPER + SHIFT + minus" (dspSeq [
            (dsp "window.float" [{action = "enable";}])
            (dsp "window.move" [
              {
                workspace = "special:scratchpad";
                follow = false;
              }
            ])
          ]))
          (bind "SUPER + minus" (dsp "workspace.toggle_special" ["scratchpad"]))

          # Sticky. floating-only
          (bind "SUPER + plus" (dsp "window.pin" []))

          # Mouse drag for floating windows.
          (bindWith {mouse = true;} "SUPER + mouse:272" (dsp "window.drag" []))
          (bindWith {mouse = true;} "SUPER + mouse:273" (dsp "window.resize" []))
        ]
        # Hardware keys (volume/brightness): repeat while held, work when locked.
        ++ map (b:
          bindWith {
            repeating = true;
            locked = true;
          }
          b.key (exec b.cmd)) [
          {
            key = "XF86AudioRaiseVolume";
            cmd = config.host.audio.cmd.volumeUp;
          }
          {
            key = "XF86AudioLowerVolume";
            cmd = config.host.audio.cmd.volumeDown;
          }
          {
            key = "XF86MonBrightnessUp";
            cmd = "${lib.getExe pkgs.brightnessctl} set +10";
          }
          {
            key = "XF86MonBrightnessDown";
            cmd = "${lib.getExe pkgs.brightnessctl} set 10-";
          }
        ]
        ++ [
          (bindWith {locked = true;} "XF86AudioMute" (exec config.host.audio.cmd.mute))
          (bindWith {locked = true;} "XF86AudioMicMute" (exec config.host.audio.cmd.micMute))
        ]
        ++ numKeyBinds;

      on._args = [
        "hyprland.start"
        (mkLuaInline ''
          function()
            hl.exec_cmd(${toLua' "${pkgs.uwsm}/bin/uwsm finalize ${lib.concatStringsSep " " (lib.attrNames sessionEnv)}"})
          end'')
      ];
    };

    submaps.resize.settings.bind =
      map (b: bindWith {repeating = true;} b.key (dsp "window.resize" [(b.delta // {relative = true;})])) [
        {
          key = "right";
          delta = {
            x = 10;
            y = 0;
          };
        }
        {
          key = "left";
          delta = {
            x = -10;
            y = 0;
          };
        }
        {
          key = "up";
          delta = {
            x = 0;
            y = -10;
          };
        }
        {
          key = "down";
          delta = {
            x = 0;
            y = 10;
          };
        }
      ]
      ++ [(bind "escape" (dsp "submap" ["reset"]))];
  };
}
