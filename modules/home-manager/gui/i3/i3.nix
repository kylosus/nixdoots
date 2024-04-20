{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./layouts.nix
  ];

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      keybindings = let
        execSpawn = cmd: "exec --no-startup-id ${cmd}";
        inherit (config.xsession.windowManager.i3.config) modifier terminal;
      in
        lib.mkOptionDefault {
          "${modifier}+Return" = execSpawn terminal;
          "${modifier}+d" = execSpawn "${lib.getExe pkgs.rofi} -show drun";
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";
          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";
          "${modifier}+x" = "exec --no-startup-id ${config.services.screen-locker.lockCmd}";
          "${modifier}+Print" = execSpawn "${lib.getBin pkgs.flameshot}/bin/flameshot gui";

          # Dunst stuff
          "Control+grave" = execSpawn "${lib.getBin pkgs.dunst}/bin/dunstctl history-pop";

          # Pulse Audio controls
          "XF86AudioRaiseVolume" = execSpawn "${lib.getBin pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = execSpawn "${lib.getBin pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = execSpawn "${lib.getBin pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute" = execSpawn "${lib.getBin pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

          # bindsym XF86AudioPlay exec "mpc toggle"
          # bindsym XF86AudioStop exec "mpc stop"
          # bindsym XF86AudioNext exec "mpc next"
          # bindsym XF86AudioPrev exec "mpc prev"

          # Brightness controls
          "XF86MonBrightnessUp" = execSpawn "${lib.getExe pkgs.brightnessctl} set +10";
          "XF86MonBrightnessDown" = execSpawn "${lib.getExe pkgs.brightnessctl} set 10-";
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
