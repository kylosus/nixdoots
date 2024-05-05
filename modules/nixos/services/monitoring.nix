{
  config,
  lib,
  ...
}: let
  cfg = config.host.monitoring;
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
      enable = false;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3000;
        };

        # security = {
        #   disable_initial_admin_creation = true;
        #   admin_user = "admin";
        #   admin_password = "admin";
        # };
      };
    };

    services.endlessh-go = {
      prometheus = {
        enable = true;
        port = 9003;
      };
    };

    services.prometheus = {
      enable = true;
      port = 9001;

      exporters = {
        node = {
          enable = true;
          enabledCollectors = ["systemd"];
          port = 9002;
        };
      };

      scrapeConfigs = [
        {
          job_name = "host-metrics";
          static_configs = [
            {
              targets = ["127.0.0.1:${builtins.toString config.services.prometheus.exporters.node.port}"];
            }
          ];
        }
      ];
    };
  };
}
