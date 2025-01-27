{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  btrfsOptions = ["relatime" "compress-force=zstd" "discard=async"];
in {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3c766251-fe69-4116-8b51-e89b86463b55";
    fsType = "btrfs";
    options = ["subvol=@/.snapshots/1/snapshot"] ++ btrfsOptions;
  };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/9f73becc-0b35-4338-a287-7517bb0d8d19";

  # Needed when /tmp on btrfs
  boot.tmp.cleanOnBoot = true;

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-uuid/3c766251-fe69-4116-8b51-e89b86463b55";
    fsType = "btrfs";
    options = ["subvol=@/.snapshots"] ++ btrfsOptions;
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/3c766251-fe69-4116-8b51-e89b86463b55";
    fsType = "btrfs";
    options = ["subvol=@/nix"] ++ btrfsOptions;
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/3c766251-fe69-4116-8b51-e89b86463b55";
    fsType = "btrfs";
    options = ["subvol=@/home"] ++ btrfsOptions;
  };

  fileSystems."/opt" = {
    device = "/dev/disk/by-uuid/3c766251-fe69-4116-8b51-e89b86463b55";
    fsType = "btrfs";
    options = ["subvol=@/opt"] ++ btrfsOptions;
  };

  fileSystems."/root" = {
    device = "/dev/disk/by-uuid/3c766251-fe69-4116-8b51-e89b86463b55";
    fsType = "btrfs";
    options = ["subvol=@/root"] ++ btrfsOptions;
  };

  fileSystems."/srv" = {
    device = "/dev/disk/by-uuid/3c766251-fe69-4116-8b51-e89b86463b55";
    fsType = "btrfs";
    options = ["subvol=@/srv"] ++ btrfsOptions;
  };

  #  fileSystems."/tmp" = {
  #    device = "tmpfs";
  #    fsType = "tmpfs";
  #  };

  fileSystems."/tmp" = {
    device = "/dev/disk/by-uuid/3c766251-fe69-4116-8b51-e89b86463b55";
    fsType = "btrfs";
    options = ["subvol=@/tmp"] ++ btrfsOptions;
  };

  fileSystems."/usr/local" = {
    device = "/dev/disk/by-uuid/3c766251-fe69-4116-8b51-e89b86463b55";
    fsType = "btrfs";
    options = ["subvol=@/usr/local"] ++ btrfsOptions;
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/3c766251-fe69-4116-8b51-e89b86463b55";
    fsType = "btrfs";
    options = ["subvol=@/var"] ++ btrfsOptions;
  };
}
