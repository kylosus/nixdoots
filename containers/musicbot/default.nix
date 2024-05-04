{
  config,
  vars,
  secrets,
  lib,
  pkgs,
  ...
}: let
  jmusicbot = pkgs.callPackage ./jmusicbot.nix {};

  name = "musicbot";
  tag = jmusicbot.version;

  # Docker image
  imageFile = pkgs.dockerTools.buildImage {
    inherit name;
    inherit tag;

    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = [pkgs.jdk11_headless jmusicbot];
      pathsToLink = ["/app"];
    };

    config = {
      WorkingDir = "/app";
      Cmd = ["${pkgs.jdk11_headless}/bin/java" "-Dnogui=true" "-jar" "${lib.getExe jmusicbot}"];
    };
  };
in {
  sops.secrets.musicbot-config = {
    format = "binary";
    sopsFile = ./config.txt;
  };

  sops.secrets.musicbot-serversettings = {
    format = "binary";
    sopsFile = ./serversettings.json;
  };

  virtualisation.oci-containers.containers = {
    musicbot = {
      autoStart = true;
      image = "${name}:${tag}";
      inherit imageFile;

      volumes = [
        "musicbot-app:/app"
        "${config.sops.secrets.musicbot-config.path}:/app/config.txt"
        "${config.sops.secrets.musicbot-serversettings.path}:/app/serversettings.json"
      ];
    };
  };
}
