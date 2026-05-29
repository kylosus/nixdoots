{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host.hyprland;

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
  # `persistent:true` shows up all of them in the bar
  workspaceAssignments = lib.flatten (
    lib.zipListsWith
    (monitor: ids: map (id: "${toString id}, monitor:${monitor.name}") ids)
    cfg.monitors
    workspaceGroups
  );

  # Build monitor strings.
  monitorEntries = map (m:
    if !m.enabled
    then "${m.name},disable"
    else "${m.name},${m.mode},${m.position},${toString m.scale},transform,${toString m.transform}")
  cfg.monitors;

  # Workspace number-key bindings:
  # SUPER+n: 0 -> 10, ALT+n 11 -> 20
  numKeyBinds = lib.flatten (map (n: let
    nStr = toString n;
    altWs = toString (n + 10);
  in [
    "SUPER, ${nStr}, workspace, ${nStr}"
    "SUPER SHIFT, ${nStr}, movetoworkspace, ${nStr}"
    "ALT, ${nStr}, workspace, ${altWs}"
    "ALT SHIFT, ${nStr}, movetoworkspace, ${altWs}"
  ]) (lib.range 1 9));

  sessionEnv = [
    "XCURSOR_THEME,Fuchsia-Pop"
    "XCURSOR_SIZE,24"
    "HYPRCURSOR_THEME,Fuchsia-Pop"
    "HYPRCURSOR_SIZE,24"
    "_JAVA_AWT_WM_NONREPARENTING,1"
    "NIXOS_OZONE_WL,1"
    "MOZ_ENABLE_WAYLAND,1"
    "QT_QPA_PLATFORM,wayland;xcb"
    "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
    "SDL_VIDEODRIVER,wayland"
    "GDK_BACKEND,wayland,x11"
    # Extra
    "_GL_GSYNC_ALLOWED,1"
    "LIBVA_DRIVER_NAME,nvidia"
    "__GLX_VENDOR_LIBRARY_NAME,nvidia"
    "ELECTRON_OZONE_PLATFORM_HINT,auto"
    "NVD_BACKEND,direct"
  ];
  sessionEnvNames = map (e: lib.head (lib.splitString "," e)) sessionEnv;
in {
  # https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager/#nixos-uwsm
  xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  wayland.windowManager.hyprland = {
    enable = true;
    # Breaks things
    # package = pkgs.stable.hyprland;

    # TODO: the keybinds are broken with lua
    configType = "hyprlang";

    # For uwsm
    systemd.enable = false;
    xwayland.enable = true;

    settings = {
      # Pull pywal-rendered $background/$foreground/$color*
      source = ["${config.xdg.cacheHome}/wal/colors-hyprland.conf"];

      # Each declared monitor first; `,preferred,auto,1` catches anything else.
      monitor = monitorEntries ++ [",preferred,auto,1"];

      workspace = workspaceAssignments;

      # Mirrors i3 visual: gaps_in 12, no titlebars, 2px borders, no rounding,
      # no animations/blur.
      general = {
        gaps_in = 12;
        gaps_out = 0;
        border_size = 2;
        layout = "dwindle";
        "col.active_border" = "$color1";
        "col.inactive_border" = "$color8";
        allow_tearing = false;

        # Animations
        animation = "global, 1, 1, default";

        # Gestures
        gesture = "3, horizontal, workspace";
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
      };

      # XWayland cursor sizing + Wayland-app conformance.
      env = sessionEnv;

      # # Window rules for scratchpad and stuff
      # Deprecated
      # windowrulev2 = [
      #   # Picture-in-Picture: float + sticky.
      #   "float, title:^(Picture-in-Picture)$"
      #   "pin, title:^(Picture-in-Picture)$"
      #   # 1Password Lock Screen: float + sticky + 800x800.
      #   "float, class:^(1Password)$, title:.*Lock Screen.*"
      #   "size 800 800, class:^(1Password)$, title:.*Lock Screen.*"
      #   "pin, class:^(1Password)$, title:.*Lock Screen.*"
      #   # Sharing Indicator: float + sticky.
      #   "float, title:.*Sharing Indicator.*"
      #   "pin, title:.*Sharing Indicator.*"
      #   # Plexamp: float.
      #   "float, title:^(Plexamp)$"
      #   # feh: float (parity with the i3 rule).
      #   "float, class:^(feh)$"
      # ];

      bind =
        [
          # Application launchers
          "SUPER, Return, exec, ${config.host.terminal.cmd.spawn}"
          "SUPER, d, exec, ${config.host.launcher.cmd.launcher}"
          "SUPER SHIFT, d, exec, ${config.host.launcher.cmd.windows}"

          # fd + rofi pipelines
          "ALT, d, exec, ${config.host.launcher.cmd.fd}"
          "ALT SHIFT, d, exec, ${config.host.launcher.cmd.fdDirs}"

          # Focus
          "SUPER, left, movefocus, l"
          "SUPER, down, movefocus, d"
          "SUPER, up, movefocus, u"
          "SUPER, right, movefocus, r"

          # Move
          "SUPER SHIFT, left, movewindow, l"
          "SUPER SHIFT, down, movewindow, d"
          "SUPER SHIFT, up, movewindow, u"
          "SUPER SHIFT, right, movewindow, r"

          # # Resize (defined in submap below)
          "SUPER, r, submap, resize"

          # Workspace cycling
          "SUPER, comma, workspace, e-1"
          "SUPER, period, workspace, e+1"
          "ALT, Tab, workspace, e+1"
          "SUPER, Tab, workspace, e-1"

          # Workspace moving
          "SUPER, 0, workspace, 10"
          "SUPER SHIFT, 0, movetoworkspace, 10"
          "ALT, 0, workspace, 20"
          "ALT SHIFT, 0, movetoworkspace, 20"

          # Misc
          "SUPER, x, exec, ${config.host.lock.command}"
          "SUPER, Print, exec, ${config.host.screenshot.command}"
          "SUPER, Print, exec, ${config.host.screenshot.command}"
          "SUPER SHIFT, INSERT, exec, ${config.host.screenshot.command}"
          "CTRL, grave, exec, ${config.host.notifications.historyCommand}"

          # Window control
          "SUPER SHIFT, q, killactive,"
          "SUPER, f, fullscreen, 0"
          "SUPER SHIFT, space, togglefloating,"

          # Scratchpad (i3-like). Two binds on the same key fire in order:
          # force floating, then move silently to the special workspace.
          "SUPER SHIFT, minus, setfloating"
          "SUPER SHIFT, minus, movetoworkspacesilent, special:scratchpad"
          "SUPER, minus, togglespecialworkspace, scratchpad"

          # Sticky. floating-only
          "SUPER, plus, pin"
        ]
        ++ numKeyBinds;

      # Hardware keys (volume/brightness/audio): use bindel for repeat.
      bindel = [
        ", XF86AudioRaiseVolume, exec, ${config.host.audio.cmd.volumeUp}"
        ", XF86AudioLowerVolume, exec, ${config.host.audio.cmd.volumeDown}"
        ", XF86MonBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} set +10"
        ", XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} set 10-"
      ];
      bindl = [
        ", XF86AudioMute, exec, ${config.host.audio.cmd.mute}"
        ", XF86AudioMicMute, exec, ${config.host.audio.cmd.micMute}"
      ];

      # Mouse drag for floating windows.
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      exec-once = [
        "${pkgs.uwsm}/bin/uwsm finalize ${lib.concatStringsSep " " sessionEnvNames}"
      ];
    };

    submaps = {
      resize.settings = {
        bind = [
          ", escape, submap, reset"
        ];

        binde = [
          ", right, resizeactive, 10 0"
          ", left, resizeactive, -10 0"
          ", up, resizeactive, 0 -10"
          ", down, resizeactive, 0 10"
        ];
      };
    };
  };
}
