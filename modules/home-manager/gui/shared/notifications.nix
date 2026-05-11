{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host.global;
  isHypr = cfg.windowManager == "hyprland";
in {
  options.host.notifications = {
    historyCommand = lib.mkOption {
      type = lib.types.str;
      description = "Shell command to pop the last dismissed notification (bound to Ctrl+`).";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (!isHypr) {
      home.packages = [pkgs.dunst];

      host.notifications.historyCommand = "${pkgs.dunst}/bin/dunstctl history-pop";

      systemd.user.services.dunst = {
        Unit = {
          Description = "Dunst notification daemon";
          PartOf = ["${config.host.session.target}"];
          After = ["pywal.service"];
          Wants = ["pywal.service"];
        };
        Service = {
          Type = "dbus";
          BusName = "org.freedesktop.Notifications";
          ExecStart = "${pkgs.dunst}/bin/dunst -conf %h/.cache/wal/dunstrc";
        };
        Install.WantedBy = ["${config.host.session.target}"];
      };
    })

    # TODO: replace with config.services.
    # It's disconnected somewhat with config in theming.nix because I had to embed pywal colors in the config
    (lib.mkIf isHypr {
      home.packages = [pkgs.mako];

      host.notifications.historyCommand = "${pkgs.mako}/bin/makoctl restore";

      systemd.user.services.mako = {
        Unit = {
          Description = "Mako notification daemon";
          PartOf = ["${config.host.session.target}"];
          After = ["pywal.service"];
          Wants = ["pywal.service"];
        };
        Service = {
          Type = "dbus";
          BusName = "org.freedesktop.Notifications";
          ExecStart = "${pkgs.mako}/bin/mako --config %h/.cache/wal/mako-config";
        };
        Install.WantedBy = ["${config.host.session.target}"];
      };
    })
  ];
}
