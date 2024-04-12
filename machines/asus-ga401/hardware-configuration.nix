{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  btrfsOptions = ["relatime" "compress-force=zstd"];
in {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7e963d58-6c88-4356-ad29-dee80ac217d4";
    fsType = "btrfs";
    options = ["subvol=@/.snapshots/1/snapshot"] ++ btrfsOptions;
  };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/9f73becc-0b35-4338-a287-7517bb0d8d19";

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-uuid/7e963d58-6c88-4356-ad29-dee80ac217d4";
    fsType = "btrfs";
    options = ["subvol=@/.snapshots"] ++ btrfsOptions;
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/7e963d58-6c88-4356-ad29-dee80ac217d4";
    fsType = "btrfs";
    options = ["subvol=@/nix"] ++ btrfsOptions;
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/7e963d58-6c88-4356-ad29-dee80ac217d4";
    fsType = "btrfs";
    options = ["subvol=@/home"] ++ btrfsOptions;
  };

  fileSystems."/opt" = {
    device = "/dev/disk/by-uuid/7e963d58-6c88-4356-ad29-dee80ac217d4";
    fsType = "btrfs";
    options = ["subvol=@/opt"] ++ btrfsOptions;
  };

  fileSystems."/root" = {
    device = "/dev/disk/by-uuid/7e963d58-6c88-4356-ad29-dee80ac217d4";
    fsType = "btrfs";
    options = ["subvol=@/root"] ++ btrfsOptions;
  };

  fileSystems."/srv" = {
    device = "/dev/disk/by-uuid/7e963d58-6c88-4356-ad29-dee80ac217d4";
    fsType = "btrfs";
    options = ["subvol=@/srv"] ++ btrfsOptions;
  };

  fileSystems."/tmp" = {
    device = "/dev/disk/by-uuid/7e963d58-6c88-4356-ad29-dee80ac217d4";
    fsType = "btrfs";
    options = ["subvol=@/tmp"] ++ btrfsOptions;
  };

  fileSystems."/usr/local" = {
    device = "/dev/disk/by-uuid/7e963d58-6c88-4356-ad29-dee80ac217d4";
    fsType = "btrfs";
    options = ["subvol=@/usr/local"] ++ btrfsOptions;
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/7e963d58-6c88-4356-ad29-dee80ac217d4";
    fsType = "btrfs";
    options = ["subvol=@/var"] ++ btrfsOptions;
  };
}
