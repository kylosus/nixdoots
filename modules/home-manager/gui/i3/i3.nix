{
  config,
  lib,
  pkgs,
  ...
}: let
  terminal = "${config.programs.urxvt.package}/bin/urxvtc";
in {
  imports = [
    ./layouts.nix
  ];

  # Needed because we don't use pkgs.rofi below
  home.packages = with pkgs; [rofi];

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      keybindings = let
        execSpawn = cmd: "exec --no-startup-id ${cmd}";
        rofiSort = "rofi -dmenu -sorting-method fzf -i -sort -refilter-timeout-limit 999999";
        inherit (config.xsession.windowManager.i3.config) modifier terminal;
      in
        lib.mkOptionDefault {
          "${modifier}+Return" = execSpawn terminal;
          # This is necessary on Arch. System applications don't show up otherwise
          "${modifier}+d" = execSpawn "rofi -show drun";
          # "${modifier}+d" = execSpawn "${lib.getExe pkgs.rofi} -show drun";
          "${modifier}+Shift+d" = execSpawn "rofi -show window";
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";
          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";
          "${modifier}+x" = "exec --no-startup-id ${config.services.screen-locker.lockCmd}";
          "${modifier}+Print" = execSpawn "${lib.getBin pkgs.stable.flameshot}/bin/flameshot gui"; # TODO: qtwebengine compile

          "Mod1+d" = execSpawn ''${lib.getExe pkgs.fd} --max-depth 7 --one-file-system . ~/ | ${rofiSort} | ${lib.getBin pkgs.findutils}/bin/xargs -I {} ${lib.getBin pkgs.xdg-utils}/bin/xdg-open "{}"'';
          "Mod1+Shift+d" = execSpawn ''${lib.getExe pkgs.fd} --max-depth 7 --one-file-system --type d . ~/ | ${rofiSort} | ${lib.getBin pkgs.findutils}/bin/xargs -I {} ${terminal} -cd "{}"'';

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
      # terminal = "${config.programs.urxvt.package}/bin/urxvtc";
      inherit terminal;

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
