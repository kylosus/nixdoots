{
  pkgs,
  lib,
  config,
  vars,
  secrets,
  ...
}: let
  ip = "${vars.container.network}.0.2";
  rtmpPort = "1935";
  name = "owncast";
  volume = "${name}-data";
in {
  sops.secrets.owncast-db = {
    format = "binary";
    sopsFile = ./owncast.db;
    mode = "0777";
  };

  # This will spin up an Alpine container with the named module and copy some filees over
  systemd.services.owncast-copy-db = {
    # https://github.com/moby/moby/issues/25245
    script = ''${lib.getExe pkgs.docker} run --rm --v ${volume}:/dest alpine cp ${config.sops.secrets.owncast-db.path} ${./logo.png} /dest/'';
    path = [pkgs.docker];
  };

  virtualisation.oci-containers.containers = {
    "${name}" = {
      autoStart = true;
      image = "ghcr.io/kylosus/owncast:latest";
      # TODO
      ports = ["${rtmpPort}:${rtmpPort}"];
      volumes = ["owncast-data:/app/data"];
      extraOptions = [
        "--net=${vars.container.networkName}"
        "--ip=${ip}"
      ];
    };
  };

  systemd.services."${config.virtualisation.oci-containers.backend}-${name}" = {
    after = [config.systemd.services.owncast-copy-db.name];
  };

  services.caddy = {
    enable = true;
    virtualHosts."${secrets.services.owncast.host}".extraConfig = ''
      reverse_proxy ${ip}:8080
    '';
  };

  services.nebula.networks."${vars.nebula.name}".firewall.inbound = [
    {
      port = rtmpPort;
      proto = "tcp";
      host = "any";
    }
  ];
}
