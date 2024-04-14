{
  pkgs,
  lib,
  ...
}: let
  common = rec {
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

    modifier = "Mod4";

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
in {
  xsession.windowManager.i3.config = common;
}
