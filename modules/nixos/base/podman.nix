{
  inputs,
  pkgs,
  lib,
  config,
  params,
  vars,
  ...
}: let
  cfg = config.host.podman;
in {
  options = {
    host.podman = {
      enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "Enables podman/docker support";
      };

      backend = lib.mkOption {
        default = "docker";
        type = lib.types.str;
        description = "Container backend to use (podman or docker)";
      };
    };
  };

  # imports = [inputs.arion.nixosModules.arion];

  config = lib.mkIf cfg.enable {
    virtualisation.containers.enable = true;
    virtualisation.oci-containers.backend = cfg.backend;

    # User to launch containers as and drop permissions (?)
    users.groups."${vars.container.user}" = {};
    users.users."${vars.container.user}" = {
      shell = null;
      uid = lib.toInt vars.container.uid;
      extraGroups = lib.mkForce [];
      isNormalUser = true;
      group = vars.container.user;
    };

    # WHY IS NIXOS LIKE THIS
    # https://github.com/NixOS/nixpkgs/issues/259770
    # https://github.com/NixOS/nixpkgs/issues/207050

    # https://nixos.wiki/wiki/Podman
    # Enable common container config files in /etc/containers
    # Probably not very clean
    virtualisation.podman = lib.mkIf (cfg.backend == "podman") {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = false;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;

      # For arion?
      dockerSocket.enable = true;
    };

    # More arion stuff
    # virtualisation.arion = lib.mkIf cfg.enableArion {
    #   backend =
    #     if cfg.backend == "podman"
    #     then "podman-socket"
    #     else "docker";
    # };
    # users.extraUsers."${params.userName}".extraGroups = lib.mkIf (cfg.enableArion && cfg.backend == "podman") ["podman"];

    # https://nixos.wiki/wiki/Docker
    virtualisation.docker = lib.mkIf (cfg.backend == "docker") {
      enable = true;

      rootless = {
        enable = lib.mkForce true;
        setSocketVariable = lib.mkForce true;
      };
    };

    # TODO: this is root?
    # https://discourse.nixos.org/t/how-to-create-docker-network-in-nixos-configuration-correctly/16945/2
    # I don't even know if this works btw
    system.activationScripts.mkContainerNetwork = let
      docker = config.virtualisation.oci-containers.backend;
      dockerBin = "${pkgs.${docker}}/bin/${docker}";
      networkName = vars.container.networkName;
      networkSubnet = vars.container.networkWithSubnet;
    in ''
      ${dockerBin} network inspect ${networkName} >/dev/null 2>&1 || ${dockerBin} network create ${networkName} --subnet ${networkSubnet}
    '';

    # users.extraGroups.docker.members = [params.userName];

    environment.systemPackages = with pkgs; [
      dive # look into docker image layers
      podman-tui # status of containers in the terminal
      podman-compose # start group of containers for dev

      docker
    ];
    # ++ (
    #   if cfg.enableArion
    #   then [
    #     # https://docs.hercules-ci.com/arion/
    #     # pkgs.arion
    #     # pkgs.docker-client
    #   ]
    #   else []
    # );

    # Example Arion:
    #     {...}: {
    #       virtualisation.arion.projects = {
    #         "gotify".settings.services."gotify".service = {
    #           image = "gotify/server:latest";
    #           restart = "unless-stopped";
    #           volumes = ["gotify-data:/app/data"];
    #           environment = {POSTGRESS_PASSWORD = "password";};
    #         };
    #       };
    #     }
  };
}
