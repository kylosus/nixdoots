{
  description = "ok";

  inputs = {
    # NixOS
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

    # Neovim in nix
    # nixvim.url = "github:nix-community/nixvim/nixos-23.11";

    # Run unpatched binaries
    # nix-alien.url = "github:thiagokokada/nix-alien";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Hardware configs
    hardware.url = "github:nixos/nixos-hardware";
    hardware.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: let
    inherit (inputs.self) outputs;

    # Static file set
    files = import ./files;

    mkNixosSystem = path: let
      inherit inputs outputs;
      params = import path inputs;
    in {
      "${params.hostname}" = inputs.nixpkgs.lib.nixosSystem {
        # inherit system specialArgs;
        specialArgs = {inherit inputs outputs files params;};
        modules =
          [./modules/nixos]
          ++ params.imports
          ++ [
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs outputs files params;};
              home-manager.users."${params.username}".imports = [./modules/home-manager];
            }
          ];
      };
    };

    mkHome = {
      inputs,
      outputs,
      params,
      ...
    }: {
      homeConfigurations."${params.username}" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${params.system}; # Home-manager requires 'pkgs' instance
        modules = [
          ./modules/home-manager
          ./modules/home-manager/home.nix
        ];
        extraSpecialArgs = {inherit inputs outputs params;};
      };
    };

    allSystems = ["x86_64-linux"];
    forAllSystems = func: (inputs.nixpkgs.lib.genAttrs allSystems func);

    mkNixosSystemsAll' = acc: element: acc // (mkNixosSystem element);
    mkNixosSystemsAll = paths: builtins.foldl' mkNixosSystemsAll' {} paths;
  in {
    # formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;
    overlays = import ./overlays {inherit inputs;};

    # Format the nix code in this flake
    formatter = forAllSystems (
      system: inputs.nixpkgs.legacyPackages.${system}.alejandra
    );

    packages = forAllSystems (
      system: allSystems.${system}.packages or {}
    );

    nixosConfigurations = mkNixosSystemsAll [./machines/asus-ga401];
  };
}
