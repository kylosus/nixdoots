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
      ../../modules/nixos/services/shadowsocks.nix
      ../../modules/nixos/services/monitoring.nix
      ../../modules/nixos/services/reverse-ssh.nix

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
    # sops.secrets.trauma-wireguard-key = {
    #   format = "binary";
    #   sopsFile = ./wireguard.key;
    # };
    # host.wireguard = {
    #   privateKeyFile = toString config.sops.secrets.trauma-wireguard-key.path;
    # };

    # networking.wireguard.interfaces.wg0 = {
    #  peers = [
    #     {
    #	  name = "Phone-OP";
    #	  publicKey = "iENbzhja/JKoCJxonufzevn2xqYxp+sDebkysNzKwAc=";
    #	  allowedIPs = [ "10.100.0.2/32" ];
    #	}
    #  ];
    # };

    # Shadowsocks, in case wireguard is blocked by DPI
    sops.secrets.trauma-shadowsocks-key = {
      format = "binary";
      sopsFile = ./shadowsocks.key;
    };
    host.shadowsocks = {
      passwordFile = config.sops.secrets.trauma-shadowsocks-key.path;
    };

    # This host has the frontend
    host.monitoring.isGrafana = true;

    host.container.enable = true;
  };

  homeModule = {...}: {
    imports = [];
  };
}
