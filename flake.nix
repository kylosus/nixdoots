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
    # PR merged from this https://github.com/nix-community/home-manager/pull/4801
    # home-manager.url = "github:kylosus/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Hardware configs
    hardware.url = "github:nixos/nixos-hardware";
    hardware.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets
    # agenix.url = "github:ryantm/agenix";
    sops-nix.url = "github:Mic92/sops-nix";

    # Maybe later
    # haumea.url = "github:nix-community/haumea/v0.2.2";
    # haumea.inputs.nixpkgs.follows = "nixpkgs";
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

    nixosConfigurations = mylib.mkNixosSystemsAll [./hosts/yue ./hosts/opium ./hosts/trauma ./hosts/kagamine];
    homeConfigurations = mylib.mkHomeAll [./hosts/yue ./hosts/emilia ./hosts/opium ./hosts/trauma ./hosts/beryl ./hosts/kagamine];

    images = {
      Opium = outputs.nixosConfigurations.Opium.config.system.build.sdImage;
    };
  };
}
