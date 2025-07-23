{functions, ...}: let
  device = "/dev/disk/by-uuid/7e963d58-6c88-4356-ad29-dee80ac217d4";
in {
  fileSystems = functions.mkBtrfs {
    inherit device;
    rootSubvol = ".snapshots/1/snapshot";
    subvols = [
      ".snapshots"
      "nix"
      "home"
      "opt"
      "root"
      "srv"
      "tmp"
      "usr/local"
      "var"
      "var/lib/portables"
      "var/lib/machines"
      "var/tmp"
    ];
  };
}
