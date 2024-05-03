{
  config,
  vars,
  secrets,
  ...
}: let
  ip = "${vars.container.network}.0.1";
  port = "8001";
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
      ports = ["${ip}:${port}:80"];
      volumes = [
        "gotify-data:/app/data"
        "${config.sops.secrets.gotify-db.path}:/app/data/gotify.db"
      ];
      environmentFiles = [
        config.sops.secrets.gotify-config.path
      ];
      extraOptions = [
        "--net=${vars.container.networkName}"
      ];
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts."${secrets.services.gotify.host}".extraConfig = ''
      reverse_proxy ${ip}:${port}
    '';
  };
}
