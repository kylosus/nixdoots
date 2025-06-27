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
      bootDisk = "/dev/disk/by-uuid/9FAA-F475";
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
      # (modulesPath + "/profiles/headless.nix")

      # Hardware
      ./hardware-configuration.nix

      # ../../modules/nixos/services/monitoring.nix

      ../../modules/nixos/features/luks-ssh.nix

      # Sites
      # ./sites.nix
    ];

    networking.nameservers = ["1.1.1.1"];

    # Internet facing, enable endlessh
    host.global.endlessh = true;

    # Optional modules
    host.nebula = {
      enable = true;
      isLighthouse = false;
    };

    host.podman.enable = true;
  };

  homeModule = {...}: {
    imports = [];
  };
}
