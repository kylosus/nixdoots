{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  device = "/dev/disk/by-uuid/3c93e531-9aa1-4650-9b9d-8c6227627467";
  btrfsOptions = ["relatime" "compress-force=zstd"];
in {
  fileSystems."/" = {
    inherit device;
    fsType = "btrfs";
    options = ["subvol=@/.snapshots/1/snapshot"] ++ btrfsOptions;
  };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/ce603dce-56f1-4ede-9e0f-bc95f4a25e65";

  # Needed when /tmp on btrfs
  boot.tmp.cleanOnBoot = true;

  fileSystems."/.snapshots" = {
    inherit device;
    fsType = "btrfs";
    options = ["subvol=@/.snapshots"] ++ btrfsOptions;
  };

  fileSystems."/nix" = {
    inherit device;
    fsType = "btrfs";
    options = ["subvol=@/nix"] ++ btrfsOptions;
  };

  fileSystems."/home" = {
    inherit device;
    fsType = "btrfs";
    options = ["subvol=@/home"] ++ btrfsOptions;
  };

  fileSystems."/opt" = {
    inherit device;
    fsType = "btrfs";
    options = ["subvol=@/opt"] ++ btrfsOptions;
  };

  fileSystems."/root" = {
    inherit device;
    fsType = "btrfs";
    options = ["subvol=@/root"] ++ btrfsOptions;
  };

  fileSystems."/srv" = {
    inherit device;
    fsType = "btrfs";
    options = ["subvol=@/srv"] ++ btrfsOptions;
  };

  fileSystems."/tmp" = {
    inherit device;
    fsType = "btrfs";
    options = ["subvol=@/tmp"] ++ btrfsOptions;
  };

  fileSystems."/usr/local" = {
    inherit device;
    fsType = "btrfs";
    options = ["subvol=@/usr/local"] ++ btrfsOptions;
  };

  fileSystems."/var" = {
    inherit device;
    fsType = "btrfs";
    options = ["subvol=@/var"] ++ btrfsOptions;
  };
}
