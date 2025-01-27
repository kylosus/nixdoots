{hardware, ...}: {
  params = {
    system = "x86_64-linux";
    timeZone = "CST6CDT";

    hostName = "Kagamine";
    userName = "user";

    desktop = false;

    fs = {
      luksDisk = "/dev/disk/by-uuid/e377df53-f8f1-4d75-a50b-21b516b94008";
      rootDisk = "/dev/disk/by-uuid/3c766251-fe69-4116-8b51-e89b86463b55";
      bootDisk = "/dev/disk/by-uuid/4935-5B64";
    };
  };

  module = {
    inputs,
    lib,
    config,
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

      ../../modules/nixos/services/monitoring.nix

      # Sites
      # ./sites.nix
    ];

    # Internet facing, enable endlessh
    host.global.endlessh = true;

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
