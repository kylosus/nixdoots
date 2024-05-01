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
    ];

    # Optional modules
    host.nebula = {
      enable = true;
      isLighthouse = true;
    };
  };

  homeModule = {...}: {
    imports = [];
  };
}
