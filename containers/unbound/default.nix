{
  config,
  vars,
  secrets,
  lib,
  pkgs,
  ...
}: let
  ip = vars.services.unbound.ip;
in {
  sops.secrets.unbound-conf = {
    format = "binary";
    sopsFile = ./unbound.conf;
    # owner = vars.container.user;
  };

  sops.secrets.unbound-a-records = {
    format = "binary";
    sopsFile = ./a-records.conf;
    owner = vars.container.user;
  };

  virtualisation.oci-containers.containers = {
    unbound = {
      autoStart = true;
      image = "docker.io/mvance/unbound";
      # user = vars.container.uid;

      volumes = [
        #"unbound-config:/opt/unbound/etc/unbound"
        "${config.sops.secrets.unbound-conf.path}:/opt/unbound/etc/unbound/unbound.conf"
        "${config.sops.secrets.unbound-a-records.path}:/opt/unbound/etc/unbound/a-records.conf"
      ];

      extraOptions = [
        "--net=${vars.container.networkName}"
        "--ip=${ip}"
      ];
    };
  };
}
