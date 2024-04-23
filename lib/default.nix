{
  inputs,
  outputs,
  files,
  ...
}: let
  mkParams = import ./params.nix {inherit files;};
  # mkNebulaHost = import ./nebula.nix {inherit files;};

  defaultSpecialArgs = {
    inherit inputs outputs files;
    secrets = inputs.secrets;
  };

  mkNixosSystem = path: let
    inherit inputs outputs;
    host = import path inputs;
    params = mkParams host.params;
  in {
    "${params.hostName}" = inputs.nixpkgs.lib.nixosSystem {
      # inherit system specialArgs;
      specialArgs = defaultSpecialArgs // {inherit params;};
      modules =
        [../modules/nixos]
        ++ [host.module]
        ++ [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = defaultSpecialArgs // {inherit params;};
            home-manager.users."${params.userName}".imports = [../modules/home-manager] ++ [host.homeModule];
          }
        ];
    };
  };

  mkHome = path: let
    inherit inputs outputs;
    host = import path inputs;
    params = mkParams host.params;
  in {
    "${params.userName}@${params.hostName}" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${params.system}; # Home-manager requires 'pkgs' instance
      modules =
        [
          ../modules/home-manager
          ../modules/home-manager/home.nix
        ]
        ++ [host.homeModule];
      extraSpecialArgs = defaultSpecialArgs // {inherit params;};
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
