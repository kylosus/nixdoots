{hardware, ...}: {
  params = {
    system = "x86_64-linux";
    timeZone = "Europe/London";

    desktop = false;

    hostName = "Trauma";
    userName = "user";
  };

  module = {
    inputs,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      # Profiles
      (modulesPath + "/profiles/headless.nix")

      # Hardware
      ./hardware-configuration.nix

      # Services
      ../../containers/gotify
      ../../containers/musicbot
      ../../containers/owncast

      ../../modules/nixos/services/monitoring.nix
    ];

    # Internet facing, enable endlessh
    host.global.endlessh = true;

    # Optional modules
    host.nebula = {
      enable = true;
      isLighthouse = true;
    };

    # This host has the frontend
    host.monitoring.isGrafana = true;

    host.podman.enable = true;
  };

  homeModule = {...}: {
    imports = [];
  };
}
