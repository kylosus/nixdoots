{
  description = "Asus G401 University Laptop";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Neovim in nix
    nixvim.url = "github:nix-community/nixvim/nixos-23.11";

    # Run unpatched binaries
    nix-alien.url = "github:thiagokokada/nix-alien";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    i3-layout = {
      url = "github:eliep/i3-layouts";
      flake = false;
    };

    # For quick hardware configuration (asus ga401)
    hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = {
    self,
    nixpkgs,
    hardware,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;

    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    params = {
      system = "x86_64-linux";
      timeZone = "Europe/Istanbul";

      hostname = "ok";
      username = "user";
      fullname = "Userly user 2";

      shell = "fish";
      terminal = "foot";
      fs = {
        luksDisk = "/dev/disk/by-uuid/357e2f86-0d91-4a42-8549-ca6213482783";
        rootDisk = "/dev/disk/by-uuid/3f1683f0-41bd-4350-9383-f8e79a4aea5c";
        bootDisk = "/dev/disk/by-uuid/E3BD-99A2";
      };
    };

    forAllSystems = nixpkgs.lib.genAttrs systems;
    systems = ["x86_64-linux"];

    nixosModules = [
      hardware.nixosModules.asus-zephyrus-ga401
      ./modules/nixos
    ];
  in rec {
    formatter.${params.system} = nixpkgs.legacyPackages.${params.system}.alejandra;

    overlays = import ./overlays {inherit inputs;};

    legacyPackages = forAllSystems (
      system:
        import nixpkgs {
          system = params.system;
          overlays = builtins.attrValues overlays;
        }
    );

    # Hardware stuff
    hardware.nvidia.prime.offload.enable = true;
    hardware.nvidia.forceFullCompositionPipeline = true;

    # NixOS configuration entrypoint
    nixosConfigurations = {
      ${params.hostname} = nixpkgs.lib.nixosSystem {
        # pkgs = legacyPackages."${params.system}";
        specialArgs = {inherit inputs outputs params;};
        modules =
          nixosModules
          ++ [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs outputs params;};
              home-manager.users."${params.username}".imports = [
                ./modules/home-manager
              ];
            }
          ];
      };
    };

    homeConfigurations."${params.username}" = home-manager.lib.homeManagerConfiguration {
      pkgs = legacyPackages.${params.system}; # Home-manager requires 'pkgs' instance
      modules = [
        ./modules/home-manager
        ./modules/home-manager/home.nix
      ];
      extraSpecialArgs = {inherit inputs outputs params;};
    };
  };
}
