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

      # From nixos-infect
      ./networking.nix

      # Services
      ../../containers/gotify
      ../../containers/musicbot
      ../../containers/owncast
    ];

    # Optional modules
    host.nebula = {
      enable = true;
      isLighthouse = true;
    };

    host.podman.enable = true;
  };

  homeModule = {...}: {
    imports = [];
  };
}
