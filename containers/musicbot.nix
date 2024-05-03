{...}: let
image = buildImage {
  name = "musicbot";
  tag = "0.3.9";

  fromImage = "docker.io/openjdk:11";
  # fromImageTag = "11";

  copyToRoot = pkgs.buildEnv {
    name = "image-root";
    paths = [ pkgs.redis ];
    pathsToLink = [ "/bin" ];
  };

  runAsRoot = ''
    #!${pkgs.runtimeShell}
    mkdir -p /app
    ${pkgs.wget} "https//github.com/jagrosh/MusicBot/releases/download/${tag}/JMusicBot-${tag}.jar -O /app"
  '';

  config = {
    Cmd = [ "java" "-Dnogui=true" "./app.jar" ];
    WorkingDir = "/app";
    # Volumes = { "/data" = { }; };
  };
}; in {
  virtualisation.oci-containers.containers = {
    gotify = {
      autoStart = true;
    };
  };
}