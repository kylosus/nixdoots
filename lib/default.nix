{
  inputs,
  outputs,
  files,
  vars,
  ...
}: let
  mkParams = import ./params.nix {inherit files;};

  defaultSpecialArgs = {
    inherit inputs outputs files vars;
    secrets = inputs.secrets;
  };

  # Everyone else reads from param directly, yet we have this here
  desktopConfigModule = {params, ...}: {host.global.desktop = params.desktop;};

  # For both nixos, and home-manager
  globalModules = [../modules desktopConfigModule];

  mkNixosSystem = path: let
    inherit inputs outputs;
    host = import path inputs;
    params = mkParams host.params;
  in {
    "${params.hostName}" = inputs.nixpkgs.lib.nixosSystem {
      system = params.system;
      # system = "x86_64-linux";
      # inherit system specialArgs;
      specialArgs =
        defaultSpecialArgs
        // {
          inherit params;
          hostPath = path;
        };
      modules =
        globalModules
        ++ [../modules/nixos]
        ++ [host.module]
        ++ [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs =
              defaultSpecialArgs
              // {
                inherit params;
                hostPath = path;
              };
            home-manager.users."${params.userName}".imports = globalModules ++ [../modules/home-manager] ++ [host.homeModule];
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
        globalModules
        ++ [
          ../modules/home-manager
          ../modules/home-manager/home.nix
        ]
        ++ [host.homeModule];
      extraSpecialArgs =
        defaultSpecialArgs
        // {
          inherit params;
          hostPath = path;
        };
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
