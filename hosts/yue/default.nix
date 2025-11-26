{hardware, ...}: {
  params = {
    system = "x86_64-linux";
    timeZone = "Europe/Istanbul";

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

      ../common/wireguard.nix
    ];

    # For crross-compiling. See https://github.com/nix-community/nixos-generators
    boot.binfmt.emulatedSystems = ["aarch64-linux"];

    hardware.nvidia.prime.offload.enable = lib.mkForce true;
    hardware.nvidia.forceFullCompositionPipeline = lib.mkForce true;

    # Suspend and lid close
    hardware.nvidia.powerManagement = {
      enable = true;
    };

    services.logind = {
      settings.Login = {
        HandleLidSwitch = "ignore";
      };
    };

    # Optional modules
    host.nebula.enable = true;
    host.container = {
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
      ifname = "wlp2s0";
      # monitors = ["HDMI-A-0" "eDP"];
      monitors = ["eDP" "HDMI-A-0"];
    };
  };
}
