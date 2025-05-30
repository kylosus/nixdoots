{
  lib,
  config,
  ...
}: let
  cfg = config.host.global;
in {
  imports = [
    ./boot.nix
    # ./dns.nix
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

  config = {
    programs.dconf.enable = cfg.desktop;
    documentation.man.enable = cfg.desktop;
  };
}
