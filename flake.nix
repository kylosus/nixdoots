{
  description = "ok";

  inputs = {
    # NixOS
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    # Neovim in nix
    # nixvim.url = "github:nix-community/nixvim/nixos-24.11";

    # Run unpatched binaries
    # nix-alien.url = "github:thiagokokada/nix-alien";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Hardware configs
    hardware.url = "github:NixOS/nixos-hardware/master";

    # Secrets
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = inputs: let
    inherit (inputs.self) outputs;

    # Static file set
    files = import ./files;
    vars = import ./vars.nix;
    secrets = import ./secrets/secrets.nix;
    mylib = import ./lib {inherit inputs outputs files vars secrets;};

    allSystems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = mylib.forAllSystems allSystems;
  in rec {
    overlays = ./overlays;

    # Format the nix code in this flake
    formatter = forAllSystems (
      system: inputs.nixpkgs.legacyPackages.${system}.alejandra
    );

    #packages = forAllSystems (
    #  system: allSystems.${system}.packages or {}
    #);

    devShells = forAllSystems (
      system: let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            fish
          ];
        };
      }
    );

    nixosConfigurations = mylib.mkNixosSystemsAll [./hosts/yue ./hosts/opium ./hosts/trauma ./hosts/kagamine ./hosts/miku];
    homeConfigurations = mylib.mkHomeAll [./hosts/yue ./hosts/emilia ./hosts/opium ./hosts/trauma ./hosts/beryl ./hosts/kagamine ./hosts/miku];

    images = {
      Opium = outputs.nixosConfigurations.Opium.config.system.build.sdImage;
    };
  };
}
