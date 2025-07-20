{
  config,
  vars,
  secrets,
  ...
}: let
  atuinPort = vars.services.atuin.port;
  atuinIp = vars.services.atuin.ip;
  atuinDbIp = vars.services.atuin.dbIp; # THIS IS HARDCODED IN ENV
in {
  sops.secrets.atuin-env = {
    format = "dotenv";
    sopsFile = ./config.env;
  };

  virtualisation.oci-containers.containers = {
    "atuin-postgres" = {
      autoStart = true;
      image = "postgres:14";
      volumes = [
        "atuin-postgres-database:/var/lib/postgresql/data/"
      ];
      environmentFiles = [
        config.sops.secrets.atuin-env.path
      ];
      extraOptions = [
        "--net=${vars.container.networkName}"
        "--ip=${atuinDbIp}"
      ];
    };
    "atuin" = {
      autoStart = true;
      image = "ghcr.io/atuinsh/atuin:latest";
      cmd = ["server" "start"];
      volumes = [
        "atuin-config:/config"
      ];
      ports = ["${atuinPort}:${atuinPort}"];
      dependsOn = ["atuin-postgres"];
      environment = {
        ATUIN_HOST = "0.0.0.0";
        ATUIN_OPEN_REGISTRATION = "true";
        RUST_LOG = "info,atuin_server=debug";
      };
      environmentFiles = [
        config.sops.secrets.atuin-env.path
      ];
      extraOptions = [
        "--net=${vars.container.networkName}"
        "--ip=${atuinIp}"
      ];
    };
  };

  # Allow atuin idk
  services.nebula.networks."${vars.nebula.name}".firewall.inbound = [
    {
      port = atuinPort;
      proto = "tcp";
      groups = [vars.nebula.trustedGroup];
    }
  ];
}
