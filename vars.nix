rec {
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
