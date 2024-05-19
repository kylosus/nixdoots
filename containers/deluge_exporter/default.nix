{
  config,
  pkgs,
  vars,
  secrets,
  ...
}: let
  name = "deluge_exporter";
  ip = "${vars.container.network}.0.4";
in {
  sops.secrets.deluge_exporter-conf = {
    format = "dotenv";
    sopsFile = ./config.env;
  };

  systemd.services."${name}-ssh-forward" = {
    description = "SSH port forward";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.openssh}/bin/ssh -o ExitOnForwardFailure=yes -i /home/user/.ssh/id_rsa.seedbox -N -L 12406:localhost:12406 trauma";
      Restart = "always";
      RestartSec = "15";
      User = "1000";
      Group = "100";
    };
  };

  virtualisation.oci-containers.containers = {
    "${name}" = {
      autoStart = true;
      image = "ghcr.io/tobbez/deluge_exporter:latest";
      volumes = [
        "deluge_exporter-data:/app"
      ];
      # environment = {
      # DELUGE_HOST = ;
      # };
      environmentFiles = [
        config.sops.secrets.deluge_exporter-conf.path
      ];
      extraOptions = [
        "--net=${vars.container.networkName}"
        "--ip=${ip}"
      ];
    };
  };

  systemd.services."${config.virtualisation.oci-containers.backend}-${name}" = let
    dep = [config.systemd.services."${name}-ssh-forward".name];
  in {
    bindsTo = dep;
    # after = dep;
    # wants = dep;
    # requires = dep;
  };
}
# docker run -e "DELUGE_HOST=172.17.0.1" -v /etc/deluge:/root/.config/deluge/ -p 9354:9354 tobbez/deluge_exporter:latest

