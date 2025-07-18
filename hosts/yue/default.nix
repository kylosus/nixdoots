{hardware, ...}: {
  params = {
    system = "x86_64-linux";
    timeZone = "CST6CDT";

    hostName = "Yue";
    userName = "user";
    fullName = "Userly user 2";

    desktop = true;

    fs = {
      luksDisk = "/dev/disk/by-uuid/9f73becc-0b35-4338-a287-7517bb0d8d19";
      rootDisk = "/dev/disk/by-uuid/7e963d58-6c88-4356-ad29-dee80ac217d4";
      bootDisk = "/dev/disk/by-uuid/F9C8-594E";
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
      hardware.nixosModules.asus-zephyrus-ga401

      # Specific config
      ../common/autorandr.nix

      # Syncthing
      ../common/syncthing.nix

      # Wine
      # ../../modules/nixos/features/wine.nix

      # Home assistant
      ../../modules/nixos/features/libvirt.nix
    ];

    # For crross-compiling. See https://github.com/nix-community/nixos-generators
    boot.binfmt.emulatedSystems = ["aarch64-linux"];

    hardware.nvidia.prime.offload.enable = lib.mkForce true;
    hardware.nvidia.forceFullCompositionPipeline = lib.mkForce true;

    networking = {
      wireless.iwd = {
        enable = true;
        settings.Settings.AutoConnect = true;
      };
      networkmanager.wifi.backend = "iwd";
    };

    programs.slock.enable = true;

    # Asus stuff
    services = {
      supergfxd.enable = true;

      # Buggy
      asusd.enable = lib.mkForce false;
    };

    services.udisks2 = {
      enable = true;
    };

    # Optional modules
    host.nebula.enable = true;
    host.podman = {
      enable = true;
      backend = "podman";
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

    host.i3 = {
      ifname = "wlan0";
      monitors = ["HDMI-A-0" "eDP"];
    };
  };
}
