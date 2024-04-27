{hardware, ...}: {
  params = {
    system = "aarch64-linux";
    timeZone = "Europe/Istanbul";

    desktop = false;

    hostName = "Opium";
    userName = "user";
    fullName = "Cockley";
  };

  module = {
    lib,
    modules,
    params,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      # Hardware
      ./hardware-configuration.nix
    ];

    # Some kind of fix for acpid
    nixpkgs.overlays = [
      (final: super: {makeModulesClosure = x: super.makeModulesClosure (x // {allowMissing = true;});})
    ];

    nixpkgs.buildPlatform.system = "x86_64-linux";
    nixpkgs.hostPlatform.system = params.system;

    boot = let
      kernelModules = ["sprdwl_ng"];
      supportedFilesystems = ["ext4" "vfat"];
    in {
      inherit kernelModules;
      initrd.systemd.enable = false;
      initrd.availableKernelModules = kernelModules;

      kernelParams = ["console=tty1" "console=ttyS0,115200"];
      inherit supportedFilesystems;
      initrd.supportedFilesystems = supportedFilesystems;

      loader = {
        grub.enable = lib.mkForce false;
        systemd-boot.enable = false;
        efi.canTouchEfiVariables = false;
      };
    };

    # Some kind of fix for wifi
    systemd.services.iwd.serviceConfig.restart = "always";

    # Mac authentication at uni
    # networking.interfaces.end0.macAddress = "";

    networking.networkmanager = {
      enable = lib.mkForce true;
      plugins = lib.mkForce [];
      ensureProfiles = {};
    };

    # Optional modules
    host.nebula.enable = true;
  };

  homeModule = {...}: {
    imports = [];
  };
}
