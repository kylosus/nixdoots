{
  config,
  params,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host.global;
  isHypr = cfg.windowManager == "hyprland";
in {
  config = lib.mkMerge [
    (lib.mkIf (!isHypr) {
      programs.feh.enable = true;

      systemd.user.services.feh = {
        Unit = {
          Description = "feh background";
          PartOf = ["${config.host.session.target}"];
          After = ["picom.service"];
        };
        Service = {
          ExecStart = "${pkgs.feh}/bin/feh --bg-fill ${params.wallpaper}";
          RemainAfterExit = true;
          Type = "oneshot";
        };
        Install.WantedBy = ["${config.host.session.target}"];
      };
    })

    (lib.mkIf isHypr {
      services.hyprpaper = {
        enable = true;

        settings = {
          ipc = "on";
          splash = false;

          wallpaper = [
            {
              # Wallpaper becomes fallback if monitor is empty
              monitor = "";
              path = "${params.wallpaper}";
            }
          ];
        };
      };
    })
  ];
}
