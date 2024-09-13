{
  lib,
  pkgs,
  config,
  vars,
  secrets,
  ...
}: let
  atuinName = "atuin";
  atuinDbName = "atuin-postgres";
  # This is so bad
  network = "10.71";
  networkName = "atuin-network";
  atuinIp = "${network}.0.2";
  atuinDbIp = "${network}.0.3"; # THIS IS HARDCODED IN ENV
in {
  sops.secrets.atuin-env = {
    format = "dotenv";
    sopsFile = ./config.env;
  };

  # https://madison-technologies.com/take-your-nixos-container-config-and-shove-it/
  systemd.services.create-atuin-network = with config.virtualisation.oci-containers; let
    backend = config.virtualisation.oci-containers.backend;
    backendBin = "${pkgs.${backend}}/bin/${backend}";
    # What the fuck
    # backendExe = "${lib.getExe pkgs."${backend}"}";
  in {
    serviceConfig.Type = "oneshot";
    wantedBy = ["${backend}-${atuinName}.service" "${backend}-${atuinDbName}.service"];
    script = ''
      ${backendBin} network inspect ${networkName} >/dev/null 2>&1 || \
      ${backendBin} network create ${networkName} --subnet ${network}.0.0/16
    '';
  };

  virtualisation.oci-containers.containers = {
    "${atuinDbName}" = {
      autoStart = true;
      image = "postgres:14";
      volumes = [
        "atuin-postgres-database:/var/lib/postgresql/data/"
      ];
      environmentFiles = [
        config.sops.secrets.atuin-env.path
      ];
      extraOptions = [
        "--net=${networkName}"
        "--ip=${atuinDbIp}"
      ];
    };
    "${atuinName}" = {
      autoStart = true;
      # I'm not going to use tagged relases
      image = "ghcr.io/atuinsh/atuin:latest";
      cmd = ["server" "start"];
      volumes = [
        "atuin-config:/config"
      ];
      ports = [ "8888:8888" ];
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
        "--net=${networkName}"
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

  # # Dumb
  # networking = {
  #   nat = {
  #     enable = true;  # Enable NAT
  #     externalInterface = "nebula.mesh";
  #     forwardPorts = [
  #       {
  #         # destination = "${atuinIp}:8888";
  #         destination = "127.0.0.1:8888";
  #         proto = "tcp";
  #         sourcePort = 8888;  # Port to listen on
  #       }
  #     ];
  #   };
  # };
}
