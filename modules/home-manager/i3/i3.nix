{
  config,
  lib,
  pkgs,
  ...
}: {
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      keybindings = let
        # execSpawn = cmd: "exec --no-startup-id ${pkgs.spawn}/bin/spawn ${cmd}";
        execSpawn = cmd: "exec --no-startup-id ${cmd}";
        inherit (config.xsession.windowManager.i3.config) modifier terminal;
      in
        lib.mkOptionDefault {
          "${modifier}+Return" = execSpawn terminal;
          "${modifier}+d" = execSpawn "${pkgs.rofi}/bin/rofi -show drun";
          #          "${modifier}+m" = execSpawn "${pkgs.emojimenu-x11}/bin/emojimenu";
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";
          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";
          "${modifier}+x" = "exec --no-startup-id ${config.services.screen-locker.lockCmd}";
          "${modifier}+Print" = execSpawn "${pkgs.flameshot}/bin/flameshot gui";

          # Dunst stuff
          "Control+grave" = execSpawn "${pkgs.dunst}/bin/dunstctl history-pop";

          # Pulse Audio controls
          "XF86AudioRaiseVolume" = execSpawn "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = execSpawn "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = execSpawn "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute" = execSpawn "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

          # bindsym XF86AudioPlay exec "mpc toggle"
          # bindsym XF86AudioStop exec "mpc stop"
          # bindsym XF86AudioNext exec "mpc next"
          # bindsym XF86AudioPrev exec "mpc prev"

          # Brightness controls
          "XF86MonBrightnessUp" = execSpawn "${pkgs.light} -A 10";
          "XF86MonBrightnessDown" = execSpawn "${pkgs.light} light -U 10";
        };

      startup = [
        {
          command = ''
            ${pkgs.systemd}/bin/systemctl --user import-environment DISPLAY; \
              ${pkgs.systemd}/bin/systemctl --user start i3-session.target
          '';
          always = false;
          notification = false;
        }
        {
          command = "${pkgs.systemd}/bin/systemctl --user restart polybar";
          always = true;
          notification = false;
        }
        {
          # command = "${pkgs.systemd}/bin/systemctl --user restart feh";
          command = "${pkgs.systemd}/bin/systemctl --user restart pywal";
          always = true;
          notification = false;
        }
      ];

      # terminal = "${lib.getExe config.programs.kitty.package} -1";
      terminal = "${config.programs.urxvt.package}/bin/urxvtc";

      window.commands = [
        {
          command = "floating enable";
          criteria.class = "feh";
        }
      ];
    };

    extraConfig = ''
      focus_wrapping no
    '';
  };
}
