{
  config,
  params,
  pkgs,
  lib,
  osConfig ? null,
  ...
}: let
  cfg = config.host.global;
  isHypr = cfg.windowManager == "hyprland";
in {
  options.host.lock = {
    command = lib.mkOption {
      type = lib.types.str;
      description = "Shell command that locks the screen.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (!isHypr) {
      home.packages = with pkgs; [slock];

      services.screen-locker = {
        enable = true;
        inactiveInterval = 5;
        lockCmd = lib.optionalString (osConfig != null) "/run/wrappers/bin/" + "slock";
        xautolock.extraOptions = ["-lockaftersleep"];
      };

      systemd.user.services = {
        xautolock-session.Install.WantedBy = lib.mkForce ["${config.host.session.target}"];
        xss-lock.Install.WantedBy = lib.mkForce ["${config.host.session.target}"];
      };

      host.lock.command = config.services.screen-locker.lockCmd;
    })

    (lib.mkIf isHypr {
      home.packages = with pkgs; [hyprlock hypridle];

      programs.hyprlock = {
        enable = true;
        settings = {
          source = "${config.xdg.cacheHome}/wal/colors-hyprland.conf";

          general = {
            hideCursor = true;
            grace = 0;
            disable_loading_bar = true;
          };

          background = {
            monitor = "";
            path = "${params.wallpaper}";
            blur_passes = 2;
            blur_size = 7;
          };

          "input-field" = {
            monitor = "";
            size = "300, 50";
            position = "0, -100";
            halign = "center";
            valign = "center";
            outline_thickness = 2;
            outer_color = "$color1";
            inner_color = "$background";
            font_color = "$foreground";
            fade_on_empty = false;
            placeholder_text = "<i>Password...</i>";
            check_color = "$color2";
            fail_color = "$color3";
          };

          label = {
            monitor = "";
            text = ''cmd[update:1000] echo "$(date +%H:%M)"'';
            color = "$foreground";
            font_size = 90;
            position = "0, 200";
            halign = "center";
            valign = "center";
          };
        };
      };

      # TODO: needs testing
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "${lib.getExe pkgs.hyprlock}";
            before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
            after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          };

          listener = [
            {
              timeout = 300;
              on_timeout = "${pkgs.systemd}/bin/loginctl lock-session";
            }
            {
              timeout = 600;
              on_timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
              on_resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
            }
          ];
        };
      };

      host.lock.command = "${pkgs.hyprlock}/bin/hyprlock";
    })
  ];
}
