{
  config,
  lib,
  vars,
  ...
}: let
  cfg = config.host.monitoring;
  grafanaPort = "3000";
  prometheusPort = "9001";
in {
  options = {
    host.monitoring = {
      isGrafana = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "Whether this host is the frontend or not";
      };
    };
  };

  config = {
    services.grafana = lib.mkIf cfg.isGrafana {
      enable = true;
      settings = {
        server = {
          http_addr = "0.0.0.0";
          http_port = lib.toInt grafanaPort;
        };

        # security = {
        #   disable_initial_admin_creation = true;
        #   admin_user = "admin";
        #   admin_password = "admin";
        # };
      };

      provision.datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:${prometheusPort}";
          }
        ];
      };
    };

    sops.secrets.geoip-db = {
      format = "binary";
      mode = "0644";
      sopsFile = ../../../secrets/files/GeoLite2-City.mmdb;
      # path = "${config.systemd.services.endlessh-go.serviceConfig.RootDirectory}/geoip-db";
    };

    services.endlessh-go = {
      prometheus = {
        enable = true;
        port = 9003;
      };

      extraOptions = [
        "-geoip_supplier=max-mind-db"
        "-max_mind_db=/geoip-db"
      ];
    };

    # Bad, bad, bad. Find a better way to do this
    systemd.services.endlessh-go-copy-db = {
      script = ''
        cp -rf ${config.sops.secrets.geoip-db.path} ${config.systemd.services.endlessh-go.serviceConfig.RootDirectory}/
      '';
    };

    systemd.services.endlessh-go = let
      dep = [config.systemd.services.endlessh-go-copy-db.name];
    in {
      after = dep;
      wants = dep;
    };

    # Fix for /run
    # systemd.services.endlessh-go.serviceConfig.PrivateTmp = lib.mkForce false;

    services.caddy.globalConfig = ''
      servers {
        metrics
      }
    '';

    services.prometheus = {
      enable = true;
      port = lib.toInt prometheusPort;

      # extraFlags = ["--web.enable-admin-api"];

      exporters = {
        node = {
          enable = true;
          enabledCollectors = ["systemd"];
          port = 9002;
        };
      };

      scrapeConfigs =
        [
          {
            job_name = "host-metrics";
            static_configs = [
              {
                targets = ["127.0.0.1:${builtins.toString config.services.prometheus.exporters.node.port}"];
              }
            ];
          }
          {
            job_name = "prometheusns-nebula";
            static_configs = [
              {
                targets = ["127.0.0.1:9004"];
              }
            ];
          }
        ]
        ++ lib.optionals config.services.caddy.enable [
          {
            job_name = "caddy";
            static_configs = [
              {
                targets = ["127.0.0.1:2019"];
              }
            ];
          }
        ]
        ++ lib.optionals config.host.global.endlessh [
          {
            job_name = "endlessh";
            static_configs = [
              {
                targets = ["127.0.0.1:${builtins.toString config.services.endlessh-go.prometheus.port}"];
              }
            ];
          }
        ];
    };

    # Expose grafana port if we are the frontend
    services.nebula.networks."${vars.nebula.name}".firewall.inbound = let
      ports = [
        prometheusPort
        "9002" # Prometheus node exporter
        "9003" # Endlessh exporter
      ];
    in
      map (x: {
        port = x;
        proto = "tcp";
        groups = [vars.nebula.trustedGroup];
      })
      (ports ++ lib.optionals cfg.isGrafana [grafanaPort]);
  };
}
