{
  config,
  lib,
  pkgs,
  ...
}: {
  # Pywal renders colors.Xresources by default; merge into ~/.Xresources so
  # polybar's ${xrdb:colorN} lookups succeed.
  xresources.extraConfig = ''#include "${config.xdg.cacheHome}/wal/colors.Xresources"'';

  xsession.enable = true;

  # X11 session bootstrap.
  home.file.".xinitrc".source = ./xinitrc;

  services.picom = {
    enable = true;
    vSync = false;
  };

  systemd.user = {
    targets.i3-session = {
      Unit = {
        Description = "i3 session";
        Documentation = ["man:systemd.special(7)"];
        BindsTo = ["graphical-session.target"];
        Wants = ["graphical-session-pre.target"];
        After = ["graphical-session-pre.target"];
      };
    };
    services = {
      terminal-daemon = {
        Unit = {
          Description = "${config.host.terminal.name} terminal (single-instance daemon)";
          PartOf = ["i3-session.target"];
          After = ["picom.service"];
        };
        Service = {
          ExecStart = config.host.terminal.cmd.daemon;
          Type = "simple";
        };
        Install.WantedBy = ["i3-session.target"];
      };

      picom.Install.WantedBy = lib.mkForce ["i3-session.target"];
    };
  };
}
