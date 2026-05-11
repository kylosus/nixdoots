{lib, ...}: {
  imports = [
    ./apps.nix
    ./audio.nix
    ./theming.nix
    ./notifications.nix
    ./launcher.nix
    ./screenshot.nix
    ./wallpaper.nix
    ./lock.nix
  ];

  options.host = {
    session = {
      target = lib.mkOption {
        type = lib.types.str;
        default = "graphical-session.target";
        description = ''
          systemd user target the WM/compositor uses to bind/start session
          services. i3 uses its own `i3-session.target`; Hyprland (with UWSM)
          attaches to the standard `graphical-session.target`.
        '';
      };
    };

    bar = {
      monitors = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = ''
          Monitor names the status bar should attach to (first = primary,
          rest = fallbacks). Typically auto-derived by the WM module from
          its own monitor list.
        '';
      };

      ifname = lib.mkOption {
        type = lib.types.str;
        default = "ens0";
        description = "Network interface for the bar's network module.";
      };

      battery = lib.mkOption {
        type = lib.types.nullOr (lib.types.submodule {
          options = {
            adapter = lib.mkOption {
              type = lib.types.str;
              description = "Power supply adapter name in /sys/class/power_supply (e.g. AC0).";
            };
            battery = lib.mkOption {
              type = lib.types.str;
              description = "Battery name in /sys/class/power_supply (e.g. BAT0).";
            };
          };
        });
        default = null;
        description = ''
          Battery configuration for the bar. null disables the battery module.
          Replaces the previous impure `builtins.readDir /sys/class/power_supply`.
        '';
      };
    };
  };
}
