{
  inputs,
  outputs,
  files,
  ...
}: let
  mkNixosSystem = path: let
    inherit inputs outputs;
    params = import path inputs;
  in {
    "${params.hostname}" = inputs.nixpkgs.lib.nixosSystem {
      # inherit system specialArgs;
      specialArgs = {inherit inputs outputs files params;};
      modules =
        [../modules/nixos]
        ++ params.nixosModules
        ++ [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs outputs files params;};
            home-manager.users."${params.username}".imports = [../modules/home-manager] ++ params.homeModules;
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
        ../modules/home-manager
        ../modules/home-manager/home.nix
      ];
      extraSpecialArgs = {inherit inputs outputs params;};
    };
  };

  forAllSystems = allSystems: func: (inputs.nixpkgs.lib.genAttrs allSystems func);
  mkNixosSystemsAll' = acc: element: acc // (mkNixosSystem element);
  mkNixosSystemsAll = paths: builtins.foldl' mkNixosSystemsAll' {} paths;
in {
  inherit forAllSystems;
  inherit mkNixosSystemsAll;
}