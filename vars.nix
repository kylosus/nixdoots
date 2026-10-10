rec {
  # Don't forget to update nixpkgs.stable.url in flake.nix
  stateVersion = "26.11";

  ssh = {
    port = 2525;
  };

  container = rec {
    # Not clean
    user = "container";
    uid = "1111";
    network = "10.70";
    networkWithSubnet = "${network}.0.0/16";
    networkName = "container-private-network";
  };

  # NixOS containers: one veth pair per container, 10.71.N.1 (host) <-> 10.71.N.2
  nixContainer = rec {
    network = "10.71";

    services = {
      jellyfin = {
        hostAddress = "${network}.0.1";
        localAddress = "${network}.0.2";
      };
    };
  };

  nebula = {
    name = "mesh";
    trustedGroup = "personal";
  };

  services = {
    gotify = {ip = "${container.network}.0.2";};
    owncast = {ip = "${container.network}.0.3";};
    unbound = {ip = "${container.network}.0.4";};
  };
}
