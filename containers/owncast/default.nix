{
  pkgs,
  lib,
  config,
  vars,
  secrets,
  ...
}: let
  ip = vars.services.owncast.ip;
  rtmpPort = "1935";
  name = "owncast";
  volume = "${name}-data";
  # uid hardcoded in owncast Dockerfile
  user = "101";
in {
  sops.secrets.owncast-db = {
    format = "binary";
    sopsFile = ./owncast.db;
  };

  # This will spin up an Alpine container with the named module and copy some files over
  systemd.services.owncast-copy-db = {
    # https://github.com/moby/moby/issues/25245
    # This is insane
    script = ''
      ${lib.getExe pkgs.docker} run --rm \
      -v ${./logo.png}:/src/logo.png \
      -v ${config.sops.secrets.owncast-db.path}:/src/owncast.db \
      -v ${volume}:/dest alpine \
      sh -c "rm -r /dest/owncast.db*;\
      cp -rf ./src/* /dest/;\
      chown ${user} -R /dest;\
      chmod 700 -R /dest"
    '';
    path = [pkgs.docker];
  };

  virtualisation.oci-containers.containers = {
    "${name}" = {
      autoStart = true;
      image = "ghcr.io/kylosus/owncast:latest";
      inherit user;
      # TODO
      ports = ["${rtmpPort}:${rtmpPort}"];
      volumes = ["owncast-data:/app/data"];
      extraOptions = [
        "--net=${vars.container.networkName}"
        "--ip=${ip}"
      ];
    };
  };

  systemd.services."${config.virtualisation.oci-containers.backend}-${name}" = let
    dep = [config.systemd.services.owncast-copy-db.name];
  in {
    after = dep;
    wants = dep;
    # requires = dep;
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
