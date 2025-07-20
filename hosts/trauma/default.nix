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
    config,
    modulesPath,
    ...
  }: {
    imports = [
      # Hardware
      ./hardware-configuration.nix

      # From nixos-infect
      ./networking.nix

      # Services
      ../../containers/gotify
      ../../containers/musicbot
      ../../containers/owncast

      # ../../modules/nixos/services/wireguard.nix
      ../../modules/nixos/services/monitoring.nix

      # Sites
      ./sites.nix
    ];

    # Just in case
    networking.networkmanager.enable = lib.mkForce false;

    # Internet facing, enable endlessh
    host.global.endlessh = true;

    # Optional modules
    host.nebula = {
      enable = true;
      isLighthouse = true;
    };

    # Wireguard
    #sops.secrets.trauma-wireguard-key = {
    #  format = "binary";
    #  sopsFile = ./wireguard.key;
    #};
    #host.wireguard = {
    #  privateKeyFile = toString config.sops.secrets.trauma-wireguard-key.path;
    #};

    # This host has the frontend
    host.monitoring.isGrafana = true;

    host.podman.enable = true;
  };

  homeModule = {...}: {
    imports = [];
  };
}
