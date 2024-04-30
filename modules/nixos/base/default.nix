{
  lib,
  config,
  ...
}: let
  cfg = config.host.global;
in {
  imports = [
    ./boot.nix
    ./filesystem.nix
    ./global-packages.nix
    ./nebula.nix
    ./network.nix
    ./nix.nix
    ./podman.nix
    ./services.nix
    ./users.nix
    ./secrets.nix
  ];

  config = lib.mkIf cfg.desktop {
    programs.dconf.enable = true;
  };
}
