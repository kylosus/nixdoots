{hardware, ...}: {
  params = {
    system = "x86_64-linux";
    timeZone = "Europe/Istanbul";

    hostName = "Yue";
    username = "user";
    fullname = "Userly user 2";

    fs = {
      luksDisk = "/dev/disk/by-uuid/9f73becc-0b35-4338-a287-7517bb0d8d19";
      rootDisk = "/dev/disk/by-uuid/7e963d58-6c88-4356-ad29-dee80ac217d4";
      bootDisk = "/dev/disk/by-uuid/2454-C7FA";
    };
  };

  homeModules = [
    ../../modules/home-manager/gui
    ../../modules/home-manager/gui/i3
  ];

  module = ({lib, ...}: {
    imports = [
      ./hardware-configuration.nix
      hardware.nixosModules.asus-zephyrus-ga401
    ];

    hardware.nvidia.prime.offload.enable = lib.mkForce true;
    hardware.nvidia.forceFullCompositionPipeline = lib.mkForce true;
  });
}