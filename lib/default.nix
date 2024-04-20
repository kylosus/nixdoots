{
  inputs,
  outputs,
  files,
  ...
}: let
  mkNixosSystem = path: let
    inherit inputs outputs;
    host = import path inputs;
    params = host.params;
  in {
    "${params.hostName}" = inputs.nixpkgs.lib.nixosSystem {
      # inherit system specialArgs;
      specialArgs = {inherit inputs outputs files params;};
      modules =
        [../modules/nixos]
        ++ [host.module]
        ++ [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs outputs files params;};
            home-manager.users."${params.username}".imports = [../modules/home-manager] ++ [host.homeModule];
          }
        ];
    };
  };

  mkHome = path: let
    inherit inputs outputs;
    host = import path inputs;
    params = host.params;
  in {
    "${params.username}@${params.hostName}" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${params.system}; # Home-manager requires 'pkgs' instance
      modules =
        [
          ../modules/home-manager
          ../modules/home-manager/home.nix
        ]
        ++ [host.homeModule];
      extraSpecialArgs = {inherit inputs outputs files params;};
    };
  };

  forAllSystems = allSystems: func: (inputs.nixpkgs.lib.genAttrs allSystems func);

  mkNixosSystemsAll' = acc: element: acc // (mkNixosSystem element);
  mkFuncAll = func: acc: element: acc // (func element);

  mkNixosSystemsAll = paths: builtins.foldl' (mkFuncAll mkNixosSystem) {} paths;
  mkHomeAll = paths: builtins.foldl' (mkFuncAll mkHome) {} paths;
in {
  inherit forAllSystems;
  inherit mkNixosSystemsAll;
  inherit mkHomeAll;
}
