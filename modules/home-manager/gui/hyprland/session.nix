{
  pkgs,
  config,
  lib,
  ...
}: {
  systemd.user.services = {
    # Polkit agent (KeePassXC, GParted, etc.)
    services.hyprpolkitagent.enable = true;

    terminal-daemon = {
      Unit = {
        Description = "${config.host.terminal.name} terminal (single-instance daemon)";
        PartOf = [config.host.session.target];
        After = lib.mkAfter ["pywal.service"];
      };
      Service = {
        ExecStart = "${pkgs.uwsm}/bin/uwsm-app -- ${config.host.terminal.cmd.daemon}";
        Type = "simple";
      };
      Install.WantedBy = [config.host.session.target];
    };
  };
}
