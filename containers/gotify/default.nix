{
  config,
  vars,
  secrets,
  ...
}: let
  ip = vars.services.gotify.ip;
in {
  sops.secrets.gotify-config = {
    format = "dotenv";
    sopsFile = ./config.env;
  };

  sops.secrets.gotify-db = {
    format = "binary";
    sopsFile = ./gotify.db;
  };

  virtualisation.oci-containers.containers = {
    gotify = {
      autoStart = true;
      image = "docker.io/gotify/server:latest";
      volumes = [
        "gotify-data:/app/data"
        "${config.sops.secrets.gotify-db.path}:/app/data/gotify.db"
      ];
      environmentFiles = [
        config.sops.secrets.gotify-config.path
      ];
      extraOptions = [
        "--net=${vars.container.networkName}"
        "--ip=${ip}"
      ];
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts."${secrets.services.gotify.host}".extraConfig = ''
      reverse_proxy ${ip}:80
    '';
  };
}
