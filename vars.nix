{
  container = rec {
    network = "10.70";
    networkWithSubnet = "${network}.0.0/16";
    networkName = "container-private-network";
  };

  nebula = {
    name = "mesh";
  };
}
