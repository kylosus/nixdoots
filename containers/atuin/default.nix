{
  config,
  vars,
  secrets,
  ...
}: let
  atuinIp = vars.services.atuin.ip;
  atuinDbIp = vars.services.atuin-db.ip; # THIS IS HARDCODED IN ENV
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
      ports = ["8888:8888"];
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
      port = "8888";
      proto = "tcp";
      groups = [vars.nebula.trustedGroup];
    }
  ];
}
