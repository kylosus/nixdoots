{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.host.i3;
in {
  options = {
    host.i3 = {
      monitors = lib.mkOption {
        default = ["eDP"];
        type = lib.types.listOf lib.types.str;
        description = "Monitors to enable";
      };
    };
  };

  config = {
    xsession.windowManager.i3.config = rec {
      # Windows key
      modifier = "Mod4";

      defaultWorkspace = "1";

      bars = [];

      floating = {
        inherit modifier;
        border = 0;
      };

      focus.followMouse = true;

      gaps = {
        inner = 12;
        outer = 0;
        # smartBorders = "on";
        # smartGaps = true;
      };

      keybindings = lib.mkOptionDefault {
        "${modifier}+0" = "workspace 10";
        "${modifier}+Shift+0" = "move container to workspace 10";
        "${modifier}+comma" = "workspace prev";
        "${modifier}+period" = "workspace next";
        "Mod1+Tab" = "workspace next";
        "Mod4+Tab" = "workspace prev";
      };

      # This language is awful
      workspaceOutputAssign = let
        monitors = lib.zipLists cfg.monitors [(lib.range 1 5) (lib.range 6 10)];
        mkWorkspace = monitor: range:
          map (x: {
            workspace = builtins.toString x;
            output = monitor;
          })
          range;
      in
        lib.flatten (map (m: (mkWorkspace m.fst m.snd)) monitors);

      window = {
        titlebar = false;
        border = 2;
        commands = [
          {
            command = "floating enable, sticky enable";
            criteria.title = "Picture-in-Picture";
          }
          {
            command = "floating enable, sticky enable, resize set width 800 800";
            criteria.title = ".*Lock Screen.*";
            criteria.class = "1Password";
          }
          {
            command = "floating enable, sticky enable";
            criteria.title = ".*Sharing Indicator.*";
          }
          {
            command = "floating enable";
            criteria.title = "Plexamp";
          }
          #        {
          #          command = "floating enable, sticky enable";
          #          criteria.app_id = "polkit-gnome-authentication-agent-1";
          #        }
        ];
      };
    };
  };
}
