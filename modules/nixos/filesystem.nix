{
  params,
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # swapDevices = [
  #   {
  #     device = "/var/lib/swapfile";
  #     size = params.fs.swapSize;
  #   }
  # ];

  fileSystems."/" = {
    device = params.fs.rootDisk;
    fsType = "ext4";
    options = ["relatime"];
  };

  fileSystems."/boot" = {
    device = params.fs.bootDisk;
    fsType = "vfat";
  };
}
