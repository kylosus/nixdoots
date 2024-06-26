{
  linuxManualConfig,
  ubootTools,
  ...
}:
(linuxManualConfig {
  version = "6.1.31-sun50iw9-gpu";
  modDirVersion = "6.1.31";

  # TODO: change to fetchFromGithub
  src = fetchGit {
    url = "https://github.com/orangepi-xunlong/linux-orangepi.git";
    rev = "f23614d875ba18f7eb5d4818fd0e92f9e536a99f";
    ref = "orange-pi-6.1-sun50iw9";
  };

  # existing makefiles for the uwe5622 driver configure themselves nondeterministically.
  # these patches remove the usage of shell calls and instead use the nix store path.
  kernelPatches = [
    {
      name = "uwe5622-makefile-remove-monkeying";
      patch = ./uwe5622-Makefile-remove-monkeying.patch;
    }
    {
      name = "uwe5622-unisocwcn-Makefile-remove-monkeying";
      patch = ./uwe5622-unisocwcn-Makefile-remove-monkeying.patch;
    }
    # {
    #   name = "uwe5622-firmware";
    #   patch = ./lib-firmware.patch;
    # }
    # {
    #   name = "enable-gpu-mali";
    #   patch = ./enable-gpu-mali.patch;
    # }
    # {
    #   name = "arch-arm64-boot-dts-allwinner-sun50i-h616-gpu";
    #   patch = ./arch-arm64-boot-dts-allwinner-sun50i-h616-gpu
    # }
    # {
    #   name = "arch-arm64-boot-dts-allwinner-sun50i-h616-gpu";
    #   patch = ./arch-arm64-boot-dts-allwinner-sun50i-h616-gpu
    # }
    {
      name = "everything";
      patch = ./megapatch.patch;
    }
  ];

  # enables several nixos-specific kernel features and properly enables wifi driver modules.
  configfile = ./sun50iw9_defconfig;
  allowImportFromDerivation = true;
})
.overrideAttrs (old: {
  # Thanks, https://github.com/ryan4yin/nixos-rk3588/blob/main/pkgs/kernel/vendor.nix
  name = "k";
  nativeBuildInputs = old.nativeBuildInputs ++ [ubootTools];
})
