{hardware, ...}: {
  params = {
    system = "x86_64-linux";
    timeZone = "CST6CDT";

    hostName = "Kagamine";
    userName = "user";

    desktop = false;

    fs = {
      luksDisk = "/dev/disk/by-uuid/ce603dce-56f1-4ede-9e0f-bc95f4a25e65";
      rootDisk = "/dev/disk/by-uuid/3c93e531-9aa1-4650-9b9d-8c6227627467";
      bootDisk = "/dev/disk/by-uuid/3C12-0864";
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

      # ../../modules/nixos/features/luks-ssh.nix

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
