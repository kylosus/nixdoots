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
    ./services.nix
    ./users.nix
    ./secrets.nix
  ];

  options = {
    host.global = {
      desktop = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "Enable graphical stuff";
      };
    };
  };

  config = lib.mkIf cfg.desktop {
    programs.dconf.enable = true;
  };
}
