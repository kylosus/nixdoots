{hardware, ...}: {
  params = {
    system = "x86_64-linux";
    timeZone = "Europe/Istanbul";

    hostName = "Miku";
    userName = "user";
    fullName = "John Kler";

    desktop = true;

    fs = {
      luksDisk = "/dev/disk/by-uuid/dd127f93-cc9f-44de-9400-145b2fac9fae";
      rootDisk = "/dev/disk/by-uuid/f43d05ae-88a0-4bb4-b656-7dc403266441";
      bootDisk = "/dev/disk/by-uuid/6FD0-8390";
    };
  };

  module = {
    lib,
    modules,
    params,
    ...
  }: {
    imports = [
      # Hardware
      ./hardware-configuration.nix
      hardware.nixosModules.common-cpu-amd-raphael-igpu
      hardware.nixosModules.common-gpu-nvidia-nonprime

      # Syncthing
      ../common/syncthing.nix

      ../common/wireguard.nix
    ];

    # TODO
    hardware.nvidia.open = true;
    hardware.nvidia.forceFullCompositionPipeline = lib.mkForce true;

    programs.slock.enable = true;

    services.udisks2 = {
      enable = true;
    };

    # Optional modules
    host.nebula.enable = true;
    host.container = {
      enable = true;
      backend = "docker";
    };
  };

  homeModule = {...}: {
    imports = [
      ../common/desktop.nix

      # Extra features
      ../../modules/home-manager/gui/features/cursor.nix
    ];

    services.udiskie = {
      enable = true;
    };

    services.polybar.config."module/temperature".hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";

    host.i3 = {
      ifname = "wlp8s0";
      monitors = ["DP-4"];
    };
  };
}
