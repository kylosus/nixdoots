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
    config = {
      keybindings = let
        execSpawn = cmd: "exec --no-startup-id ${cmd}";
        inherit (config.xsession.windowManager.i3.config) modifier;
      in
        lib.mkOptionDefault {
          "${modifier}+Return" = execSpawn config.host.terminal.cmd.spawn;
          # This is necessary on Arch. System applications don't show up otherwise
          "${modifier}+d" = execSpawn config.host.launcher.cmd.launcher;
          "${modifier}+Shift+d" = execSpawn config.host.launcher.cmd.windows;
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";
          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";
          "${modifier}+x" = execSpawn config.host.lock.command;
          "${modifier}+Print" = execSpawn config.host.screenshot.command;

          "Mod1+d" = execSpawn config.host.launcher.cmd.fd;
          "Mod1+Shift+d" = execSpawn config.host.launcher.cmd.fdDirs;

          # Notification history (dunst on i3, mako on Hyprland)
          "Control+grave" = execSpawn config.host.notifications.historyCommand;

          # Pulse Audio controls
          "XF86AudioRaiseVolume" = execSpawn "${config.host.audio.cmd.volumeUp}";
          "XF86AudioLowerVolume" = execSpawn "${config.host.audio.cmd.volumeDown}";
          "XF86AudioMute" = execSpawn "${config.host.audio.cmd.mute}";
          "XF86AudioMicMute" = execSpawn "${config.host.audio.cmd.micMute}";

          # TODO
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
          command = "${pkgs.systemd}/bin/systemctl --user restart pywal";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.systemd}/bin/systemctl --user restart feh";
          always = true;
          notification = false;
        }
      ];

      terminal = config.host.terminal.cmd.spawn;

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
