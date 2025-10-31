{
  pkgs,
  config,
  lib,
  params,
  secrets,
  hostPath,
  vars,
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

  config = let
    name = vars.nebula.name;
    tunDevice = "nebula.${name}";

    sopsKey = "${params.hostName}-nebula-key";
    sopsCert = "${params.hostName}-nebula-cert";
    owner = config.systemd.services."nebula@${name}".serviceConfig.User;

    mkSecret = sopsFile: {
      format = "binary";
      inherit sopsFile;
      inherit owner;
    };

    accumulatePorts = acc: item: let
      proto = item.proto;
      port = item.port;
      existingPorts =
        if acc ? ${proto}
        then acc.${proto}
        else [];
    in
      acc // {${proto} = existingPorts ++ [(lib.toInt port)];};
  in
    lib.mkIf (cfg.enable) {
      environment.systemPackages = with pkgs; [nebula];

      # Global secreet
      sops.secrets.nebula-ca = mkSecret ../../../secrets/nebula/ca.json;

      # Host-specific secrets
      sops.secrets."${sopsKey}" = mkSecret "${hostPath}/nebula/key.json";
      sops.secrets."${sopsCert}" = mkSecret "${hostPath}/nebula/cert.json";

      services.nebula.networks."${name}" = let
        lighthouseIps = map (x: x.routable-ip) secrets.nebula.lighthouses;
      in rec {
        enable = true;
        # TODO
        isLighthouse = cfg.isLighthouse;

        lighthouses = map (x: x.nebula-ip) secrets.nebula.lighthouses;

        staticHostMap = builtins.listToAttrs (map (lh: {
            name = lh.nebula-ip;
            value = [lh.routable-ip];
          })
          secrets.nebula.lighthouses);

        isRelay = isLighthouse;
        relays = map (x: x.nebula-ip) secrets.nebula.relays;

        tun = {
          # disable = lib.mkForce true;
          device = tunDevice;
        };

        settings = {
          lighthouse.dns = lib.mkIf cfg.isLighthouse {
            host = "0.0.0.0";
            port = 53;
          };

          # TODO
          # stats = lib.mkIf cfg.isLighthouse {
          #   type = "prometheus";
          #   listen = "127.00.0.1:9004";

          #   namespace = "prometheusns";
          #   interval = "10s";
          #   path = "/metrics";
          #   subsystem = "nebula";

          #   message_metricis = true;
          #   lighthouse_metrics = true;
          # };
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
            port = builtins.toString vars.ssh.port;
            proto = "tcp";
            groups = [vars.nebula.trustedGroup];
          }

          # Just in case
          {
            port = "22";
            proto = "tcp";
            groups = [vars.nebula.trustedGroup];
          }
        ];

        # Default ca for everyone
        ca = config.sops.secrets.nebula-ca.path;
        # Rest from the config
        key = config.sops.secrets."${sopsKey}".path;
        cert = config.sops.secrets."${sopsCert}".path;
      };

      # DNS
      # networking.nameservers = lighthouses;

      # Open the chosen ports
      networking.firewall.interfaces."${tunDevice}" = let
        filteredPorts = lib.unique (builtins.filter (x: x.port != "any") config.services.nebula.networks."${name}".firewall.inbound);
        ports = builtins.foldl' accumulatePorts {} filteredPorts;
      in {
        allowedTCPPorts = ports.tcp or [];
        allowedUDPPorts = ports.udp or [];
      };

      systemd.services."nebula@${name}".after = ["sops-nix.service"];
    };
}
