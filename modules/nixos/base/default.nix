{...}: {
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
}
