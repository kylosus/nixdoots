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

  fileSystems."/" = lib.mkDefault {
    device = params.fs.rootDisk;
    fsType = "ext4";
    options = ["relatime"];
  };

  fileSystems."/boot" = lib.mkIf (builtins.hasAttr "bootDisk" params.fs) (lib.mkDefault {
    device = params.fs.bootDisk;
    fsType = "vfat";
  });
}
