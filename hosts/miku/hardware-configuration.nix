{functions, ...}: let
  device = "/dev/disk/by-uuid/f43d05ae-88a0-4bb4-b656-7dc403266441";
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
    ];
  };
}
