{
  pkgs,
  config,
  lib,
  params,
  secrets,
  hostPath,
  ...
}: let
  cfg = config.host.nebula;
in {
  options = {
    host.nebula = {
      enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "Enables nebula support";
      };

      isLighthouse = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "Whether this host is a lighthouse or not";
      };

      keys = lib.mkOption {
        type = lib.types.submodule {
          options = {
            key = lib.mkOption {
              type = lib.types.path;
              description = "Path for the host key";
            };

            cert = lib.mkOption {
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

    mkSecret = sopsFile: {
      format = "binary";
      inherit sopsFile;
      inherit owner;
    };

    lighthouses = [secrets.nebula.ip];
  in
    lib.mkIf (cfg.enable) {
      environment.systemPackages = with pkgs; [nebula];

      # Global secreet
      sops.secrets.nebula-ca = mkSecret ../../../secrets/nebula/ca.json;

      # Host-specific secrets
      sops.secrets."${sopsKey}" = mkSecret "${hostPath}/nebula/key.json";
      sops.secrets."${sopsCert}" = mkSecret "${hostPath}/nebula/cert.json";

      services.nebula.networks.mesh = let
        lighthouseIps = map (x: x.routable-ip) secrets.nebula.lighthouses;
      in rec {
        enable = true;
        # TODO
        isLighthouse = cfg.isLighthouse;
        inherit lighthouses;
        staticHostMap = {"${secrets.nebula.ip}" = lighthouseIps;};

        isRelay = isLighthouse;
        relays = [secrets.nebula.ip];

        settings = {
          lighthouse.dns = lib.mkIf cfg.isLighthouse {
            host = "0.0.0.0";
            port = 53;
          };
        };

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

      # DNS
      networking.nameservers = lighthouses;

      systemd.services."nebula@mesh".after = ["sops-nix.service"];
    };
}
