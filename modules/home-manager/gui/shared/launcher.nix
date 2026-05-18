{
  config,
  pkgs,
  lib,
  ...
}: let
  isHypr = config.host.global.windowManager == "hyprland";

  appLauncherPrefix = lib.optionalString isHypr "${pkgs.uwsm}/bin/uwsm-app -- ";
in {
  options.host.launcher = {
    name = lib.mkOption {
      default = "rofi";
      type = lib.types.enum ["rofi"];
      description = "Application launcher to use";
    };

    cmd = {
      launcher = lib.mkOption {
        type = lib.types.str;
        description = "Launcher command to execute";
      };

      windows = lib.mkOption {
        type = lib.types.str;
        description = "Command to list windows";
      };

      fd = lib.mkOption {
        type = lib.types.str;
        description = "Command to list files and open";
      };

      fdDirs = lib.mkOption {
        type = lib.types.str;
        description = "Command to list directories and open in a terminal";
      };
    };
  };

  config = {
    programs.rofi = {
      enable = true;
      font = "source code pro medium 10";
      terminal = lib.getExe config.programs.kitty.package;
      extraConfig = {
        modi = "drun";
        show-icons = true;
        case-sensitive = false;
      };
    };

    home.packages = with pkgs; [
      fd
      findutils
      xdg-utils
    ];

    assertions = [
      {
        assertion = config.host.launcher.name == "rofi";
        message = "Only rofi launcher is supported for now";
      }
    ];

    host.launcher.cmd = let
      rofiSort = "${pkgs.rofi}/bin/rofi -dmenu -sorting-method fzf -i -sort -refilter-timeout-limit 999999";
      # Tell rofi's drun mode to wrap each launched .desktop entry in uwsm-app.
      runCommand = lib.optionalString isHypr " -run-command '${pkgs.uwsm}/bin/uwsm-app -- {cmd}'";
    in {
      launcher = "${lib.getExe pkgs.rofi} -show drun${runCommand}";
      windows = "${lib.getExe pkgs.rofi} -show window";

      fd = ''${lib.getExe pkgs.fd} --max-depth 7 --one-file-system . ~/ | ${rofiSort} | ${lib.getBin pkgs.findutils}/bin/xargs -I {} ${appLauncherPrefix}${lib.getBin pkgs.xdg-utils}/bin/xdg-open "{}"'';
      fdDirs = ''${lib.getExe pkgs.fd} --max-depth 7 --one-file-system --type d . ~/ | ${rofiSort} | ${lib.getBin pkgs.findutils}/bin/xargs -I {} ${config.host.terminal.cmd.cd "{}"}'';
    };
  };
}
