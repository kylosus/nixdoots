{
  pkgs,
  config,
  lib,
  params,
  secrets,
  ...
}: let
  cfg = config.host.nebula;
in {
  options = {
    host.nebula = {
      enable = lib.mkOption {
        default = true;
        type = lib.types.bool;
        description = "Enables nebula support";
      };

      isLighthouse = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "Whether this host is a lighthouse or not";
      };

      # keys = lib.mkOption {
      #   # default = ["eDP"];
      #   type = lib.types.attrsOf lib.types.path;
      #   description = "Node key and cert";
      #   example = ''{ key = /path/to/key; cert = /path/to/cert; }'';
      # };

      keys = lib.mkOption {
        # default = ["eDP"];
        type = lib.types.submodule {
          options = {
            key = lib.mkOption {
              # TODO: bad types
              # type = lib.types.attrsOf lib.types.anything;
              type = lib.types.path;
              description = "Path for the host key";
            };

            cert = lib.mkOption {
              # type = lib.types.attrsOf lib.types.anything;
              type = lib.types.path;
              description = "Path for host cert";
            };
          };
        };
        description = "Node key and cert";
        example = ''{ key = /path/to/key; cert = /path/to/cert; }'';
      };
    };
  };

  # config = lib.mkIf (cfg.enable) {
  config = let
    sopsKey = "${params.hostName}-nebula-key";
    sopsCert = "${params.hostName}-nebula-cert";
    owner = config.systemd.services."nebula@mesh".serviceConfig.User;
  in {
    environment.systemPackages = with pkgs; [nebula];
    sops.secrets.nebula-ca = {
      format = "binary";
      sopsFile = ../../../secrets/nebula/ca.yaml;
    };

    sops.secrets."${sopsKey}" = {
      format = "binary";
      sopsFile = cfg.keys.key;
      inherit owner;
    };

    sops.secrets."${sopsCert}" = {
      format = "binary";
      sopsFile = cfg.keys.cert;
      inherit owner;
    };

    services.nebula.networks.mesh = {
      enable = true;
      # TODO
      isLighthouse = cfg.isLighthouse;
      lighthouses = [secrets.nebula.ip];
      staticHostMap = {"${secrets.nebula.ip}" = map (x: x.routable-ip) secrets.nebula.lighthouses;};

      firewall.outbound = [
        {
          port = "any";
          proto = "any";
          host = "any";
        }
      ];

      firewall.inbound = [
        # Allow ping from anyone
        {
          port = "any";
          proto = "icmp";
          host = "any";
        }

        # Allow ssh among personal devices
        {
          port = "22";
          proto = "tcp";
          groups = ["personal"];
        }
      ];

      # Default ca for everyone
      ca = config.sops.secrets.nebula-ca.path;
      # Rest from the config
      key = config.sops.secrets."${sopsKey}".path;
      cert = config.sops.secrets."${sopsCert}".path;
    };

    sops.secrets.nebula-ca.owner = config.systemd.services."nebula@mesh".serviceConfig.User;

    # sops.secrets."${sopsKey}".owner = config.systemd.services."nebula@mesh".serviceConfig.User;
    # sops.secrets."${sopsCert}".owner = config.systemd.services."nebula@mesh".serviceConfig.User;

    # sops.secrets."${cfg.keys.key.name}".owner = config.systemd.services."nebula@mesh".serviceConfig.User;

    # cfg.keys.key.owner = config.systemd.services."nebula@mesh".serviceConfig.User;
    # cfg.keys.cert.owner = config.systemd.services."nebula@mesh".serviceConfig.User;

    # systemd.services."nebula@mesh".After = [ "sops-nix.service" ];
    # systemd.services."nebula@mesh".Unit = [];
    systemd.services."nebula@mesh".after = ["sops-nix.service"];
  };
}
