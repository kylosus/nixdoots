{hardware, ...}: {
  params = {
    system = "x86_64-linux";
    timeZone = "CST6CDT";

    hostName = "Kagamine";
    userName = "user";

    desktop = false;

    fs = {
      luksDisk = "/dev/disk/by-uuid/01ceb48e-62c0-4fb3-8016-7cb31396164d";
      rootDisk = "/dev/disk/by-uuid/d21e2e21-249a-4643-807a-c74e9c05dc0e";
      bootDisk = "/dev/disk/by-uuid/F730-7892";
    };
  };

  module = {
    inputs,
    lib,
    config,
    ...
  }: {
    imports = [
      # Hardware
      ./hardware-configuration.nix

      # ../../modules/nixos/services/monitoring.nix

      ../../modules/nixos/features/luks-ssh.nix
    ];

    # ZFS stuff
    boot.supportedFilesystems = ["zfs"];
    # This is random
    networking.hostId = "6f1b942e";

    boot.crashDump.enable = true;

    host.nebula = {
      enable = true;
      isLighthouse = true;
    };
  };

  homeModule = {...}: {
    imports = [];
  };
}
