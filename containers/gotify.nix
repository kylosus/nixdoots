{
  vars,
  secrets,
  ...
}: let
  ip = "${vars.container.network}.0.1";
  port = "8001";
in {
  virtualisation.oci-containers.containers = {
    gotify = {
      autoStart = true;
      image = "docker.io/gotify/server:latest";
      ports = ["${ip}:${port}:80"];
      volumes = ["gotify-data:/app/data"];
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
