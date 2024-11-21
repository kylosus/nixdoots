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
      ifname = lib.mkOption {
        default = "ens0";
        type = lib.types.str;
        description = "Network interface name to use in Polybar";
      };
      monitors = lib.mkOption {
        default = ["eDP"];
        type = lib.types.listOf lib.types.str;
        description = "Monitors to enable";
      };
    };
  };

  config = let
    # Windows key
    modifier = "Mod4";
    # alt
    altModifier = "Mod1";
  in {
    xsession.windowManager.i3.config = rec {
      inherit modifier;

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

      keybindings = lib.mkOptionDefault ({
          "${modifier}+0" = "workspace 10";
          "${modifier}+Shift+0" = "move container to workspace 10";
          "${modifier}+comma" = "workspace prev";
          "${modifier}+period" = "workspace next";
          "Mod1+Tab" = "workspace next";
          "Mod4+Tab" = "workspace prev";

          # Handle this one separately
          "${altModifier}+0" = "workspace 20";
          "${altModifier}+Shift+0" = "move container to workspace 20";
        }
        // lib.mergeAttrsList (map (x: let
          xStr = builtins.toString x;
          workspace = builtins.toString (x + 10);
        in {
          "${altModifier}+${xStr}" = "workspace ${workspace}";
          "${altModifier}+Shift+${xStr}" = "move container to workspace ${workspace}";
        }) (lib.range 1 10)));

      # This language is awful
      workspaceOutputAssign = let
        monitors = lib.zipLists cfg.monitors [
          ((lib.range 1 5) ++ (lib.range 11 15))
          ((lib.range 6 10) ++ (lib.range 16 20))
        ];
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
