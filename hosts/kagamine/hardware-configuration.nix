{functions, ...}: let
  device = "/dev/disk/by-uuid/d21e2e21-249a-4643-807a-c74e9c05dc0e";
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
