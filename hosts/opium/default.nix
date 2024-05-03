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
    inputs,
    lib,
    modules,
    params,
    secrets,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      # Hardware
      ./hardware-configuration.nix
    ];

    # Probably not necessary
    services.xserver.enable = lib.mkForce false;
    environment.noXlibs = lib.mkForce true;

    # Some kind of fix for acpid
    nixpkgs.overlays = [
      (final: super: {makeModulesClosure = x: super.makeModulesClosure (x // {allowMissing = true;});})
      # Hopefully lock it in so I don't have to keep compiling
      # (final: super: { pkgs = import inputs.nixpkgs-stable {}; })
    ];

    # nixpkgs.config.pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux.pkgsCross.aarch64-multiplatform;

    nixpkgs.buildPlatform.system = "x86_64-linux";
    nixpkgs.hostPlatform.system = params.system;

    # Some kind of fix for wifi
    systemd.services.iwd.serviceConfig.restart = "always";

    # Mac authentication at uni
    networking.interfaces.end0.macAddress = secrets.hosts.titan.macAddress;

    networking.networkmanager = {
      enable = lib.mkForce true;
      ensureProfiles = {};
    };

    # Optional modules
    host.nebula.enable = true;
  };

  homeModule = {...}: {
    imports = [];
  };
}
