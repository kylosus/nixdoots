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
      sopsFile = ../../../secrets/files/GeoLite2-City.mmdb;
      path = "${config.systemd.services.endlessh-go.serviceConfig.RootDirectory}/geoip-db";
    };

    services.endlessh-go = {
      prometheus = {
        enable = false;
        port = 9003;
      };

      extraOptions = [
        "-geoip_supplier=max-mind-db"
        "-max_mind_db=/geoip-db"
      ];
    };

    # Fix for /run
    systemd.services.endlessh-go.serviceConfig.PrivateTmp = lib.mkForce false;

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
