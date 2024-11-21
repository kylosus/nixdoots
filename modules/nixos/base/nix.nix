{
  params,
  inputs,
  outputs,
  lib,
  config,
  functions,
  ...
}: {
  # TODO: share between nixos and home-manager
  nixpkgs = {
    hostPlatform = lib.mkDefault params.system;

    overlays = functions.mkOverlays outputs.overlays {inherit inputs lib config;};

    config = {
      allowUnfree = true;
    };
  };

  nix.settings = {
    experimental-features = "nix-command flakes cgroups";
    auto-optimise-store = true;
    log-lines = lib.mkDefault 25;

    use-cgroups = true;

    # Needed for remote deploys
    trusted-users = ["@wheel"];

    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];

  nix.daemonCPUSchedPolicy = lib.mkDefault "batch";
  nix.daemonIOSchedClass = lib.mkDefault "idle";
  nix.daemonIOSchedPriority = lib.mkDefault 7;

  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  programs.command-not-found.enable = false;

  # TODO: temporary
  programs.ssh = {
    startAgent = true;
  };

  # TODO: put this in vars.nix or something
  system.stateVersion = "24.05";
}
