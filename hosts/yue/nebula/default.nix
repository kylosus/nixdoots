{config, ...}: {
  imports = [
    ../../../modules/nixos/services/nebula.nix
  ];

  config = {
    host.nebula.keys = {
      cert = ./cert.yaml;
      key = ./key.yaml;
    };
  };
}
