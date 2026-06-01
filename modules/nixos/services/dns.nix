{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.dns;
  port = 53;

  secretName = zone: "knot-zone-${zone.domain}";

  mkZoneFile = zone:
    pkgs.writeText "${zone.domain}.zone" ''
      $ORIGIN ${zone.domain}.
      $TTL 3600
      @ IN SOA ns1.${zone.domain}. hostmaster.${zone.domain}. (
          1          ; serial (knot rewrites via zonefile-load = difference-no-serial)
          3600       ; refresh (1h)
          900        ; retry   (15m, RFC 1912)
          1209600    ; expire  (2w,  RFC 1912)
          3600       ; minimum (1h negative cache, RFC 2308)
      )
      @ IN NS ns1.${zone.domain}.
      ns1 IN A ${cfg.dnsListenAddr}
      ${lib.concatMapStringsSep "\n" (r: "${r.name} IN A ${r.ip}") zone.records}
    '';

  zoneFilePath = zone:
    if zone.sopsFile != null
    then config.sops.secrets.${secretName zone}.path
    else mkZoneFile zone;

  sopsZones = lib.filter (z: z.sopsFile != null) cfg.zones;
in {
  options = {
    host.dns = {
      dnsListenAddr = lib.mkOption {
        type = lib.types.str;
        description = "IP address knot listens on.";
      };

      zones = lib.mkOption {
        default = [];
        type = lib.types.listOf (lib.types.submodule {
          options = {
            domain = lib.mkOption {
              type = lib.types.str;
              description = "Zone apex domain.";
            };
            sopsFile = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = ''
                              Path to a sops-encrypted zone file. The modules handles the
                owner/group for knot. Mutually exclusive with `records`.
              '';
            };
            records = lib.mkOption {
              type = lib.types.listOf (lib.types.submodule {
                options = {
                  name = lib.mkOption {
                    type = lib.types.str;
                    description = "Record name within the zone (`@` for apex).";
                  };
                  ip = lib.mkOption {
                    type = lib.types.str;
                    description = "IPv4 address for an A record.";
                  };
                };
              });
              default = [];
              description = ''
                Simple A records used to generate a zone file at build time.
                Mutually exclusive with `sopsFile`.
              '';
            };
          };
        });
      };
    };
  };

  config = {
    assertions =
      map (zone: {
        assertion = (zone.sopsFile != null) != (zone.records != []);
        message = "host.dns.zones for ${zone.domain}: exactly one of `sopsFile` or `records` must be set.";
      })
      cfg.zones;

    sops.secrets = lib.listToAttrs (map (zone:
      lib.nameValuePair (secretName zone) {
        format = "binary";
        sopsFile = zone.sopsFile;
        owner = "knot";
        group = "knot";
      })
    sopsZones);

    services.knot = {
      enable = true;
      settings = {
        server.listen = ["${cfg.dnsListenAddr}@${lib.toString port}"];

        template = [
          {
            id = "default";
            semantic-checks = "on";
            dnssec-signing = "on";
            dnssec-policy = "default";
            zonefile-load = "difference-no-serial";
            journal-content = "all";
            global-module = "mod-rrl/default";
          }
        ];

        policy = [
          {
            id = "default";
            algorithm = "ECDSAP256SHA256";
            nsec3 = "on";
            nsec3-iterations = 0;
            nsec3-salt-length = 0;
          }
        ];

        mod-rrl = [
          {
            id = "default";
            rate-limit = 200;
            slip = 2;
          }
        ];

        zone =
          map (z: {
            domain = z.domain;
            file = zoneFilePath z;
          })
          cfg.zones;
      };
    };

    networking.firewall.allowedTCPPorts = [port];
    networking.firewall.allowedUDPPorts = [port];
  };
}
