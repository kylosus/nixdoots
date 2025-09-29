{functions, ...}: let
  device = "/dev/disk/by-uuid/d21e2e21-249a-4643-807a-c74e9c05dc0e";
in {
  boot.kernelModules = ["kvm-intel"];

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
