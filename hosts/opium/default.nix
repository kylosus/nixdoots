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

    # Probably not necessary
    services.xserver.enable = lib.mkForce false;
    environment.noXlibs = lib.mkForce true;

    # Some kind of fix for acpid
    nixpkgs.overlays = [
      (final: super: {makeModulesClosure = x: super.makeModulesClosure (x // {allowMissing = true;});})
    ];

    nixpkgs.buildPlatform.system = "x86_64-linux";
    nixpkgs.hostPlatform.system = params.system;

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
