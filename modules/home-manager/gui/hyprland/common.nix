{
  config,
  lib,
  ...
}: let
  cfg = config.host.hyprland;
in {
  options.host.hyprland = {
    ifname = lib.mkOption {
      type = lib.types.str;
      default = "ens0";
      description = "Network interface name for the bar's network module.";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Monitor connector name (e.g. \"HDMI-A-1\", \"eDP-1\").";
          };
          mode = lib.mkOption {
            type = lib.types.str;
            default = "preferred";
            description = "Mode string, e.g. \"1920x1080@144\" or \"preferred\".";
          };
          position = lib.mkOption {
            type = lib.types.str;
            default = "auto";
            description = "Position string, e.g. \"0x0\" or \"auto\".";
          };
          scale = lib.mkOption {
            type = lib.types.float;
            default = 1.0;
            description = "Scale factor.";
          };
          transform = lib.mkOption {
            type = lib.types.int;
            default = 0;
            description = "Rotation/transform: 0=normal, 1=90°, 2=180°, 3=270°.";
          };
          bitdepth = lib.mkOption {
            type = lib.types.nullOr (lib.types.enum [8 10]);
            default = null;
            description = "Output bit depth. Set to 10 on wide-gamut/HDR panels so colour management can switch to wide gamut (e.g. fullscreen video). null = Hyprland default (8).";
          };
          extraSettings = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = {};
            example = {
              cm = "hdr";
              sdrbrightness = 1.2;
            };
            description = "Extra keys merged into this monitor's hl.monitor() rule (cm, sdr_eotf, sdrbrightness, vrr, ...).";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to enable this monitor.";
          };
        };
      });
      default = [];
      description = "Monitor configuration. Order matters: first = primary.";
    };
  };

  config = {
    # Forward into the WM-agnostic bar namespace.
    host.bar = {
      monitors = map (m: m.name) cfg.monitors;
      ifname = cfg.ifname;
    };
  };
}
