{...}: {
  imports = [
    ./boot.nix
    ./filesystem.nix
    ./global-packages.nix
    ./network.nix
    ./nix.nix
    ./services.nix
    ./users.nix
    ./secrets.nix
  ];
}
