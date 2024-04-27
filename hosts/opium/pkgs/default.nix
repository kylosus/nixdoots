pkgs: rec {
  linux = import ./linux pkgs;
  armbianFirmware = pkgs.callPackage ./armbian-firmware {};
  uboot = pkgs.callPackage ./uboot {};
}
