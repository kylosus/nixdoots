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

  fileSystems."/" = lib.mkDefault {
    device = params.fs.rootDisk;
    fsType = "ext4";
    options = ["relatime"];
  };

  fileSystems."/boot" = lib.mkIf (builtins.hasAttr "bootDisk" params.fs) (lib.mkDefault {
    device = params.fs.bootDisk;
    fsType = "vfat";
  });

  boot.initrd.luks.devices."cryptroot" = lib.mkIf (builtins.hasAttr "luksDisk" params.fs) {
    device = params.fs.luksDisk;
  };

  # Needed when /tmp on btrfs
  boot.tmp.cleanOnBoot = true;
}
