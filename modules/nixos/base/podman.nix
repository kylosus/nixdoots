{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.host.podman;
in {
  options = {
    host.podman = {
      enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "Enables podman support";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # https://nixos.wiki/wiki/Podman
    # Enable common container config files in /etc/containers
    virtualisation.containers.enable = true;
    virtualisation = {
      podman = {
        enable = true;

        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = false;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    # Useful otherdevelopment tools
    environment.systemPackages = with pkgs; [
      dive # look into docker image layers
      podman-tui # status of containers in the terminal
      podman-compose # start group of containers for dev
    ];
  };
}
