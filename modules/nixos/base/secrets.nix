{
  config,
  inputs,
  lib,
  outputs,
  pkgs,
  params,
  ...
}: let
  inherit (params) hostName;

  # I know this might be bad
  hostSecretsFile = ../../hosts/${hostName}/secrets/secrets.yaml;
  hostSecrets =
    if builtins.pathExists hostSecretsFile
    then {"${hostName}".sopsFile = hostSecretsFile;}
    else {};

  cfg = config.host.feature.secrets;
in
  with lib; {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    options = {
      host.feature.secrets = {
        enable = mkOption {
          default = true;
          type = with types; bool;
          description = "Enables secrets support";
        };
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        age
        gnupg
        pinentry.out
        ssh-to-age
        ssh-to-pgp
        sops
      ];

      sops = {
        # age.sshKeyPaths = map getKeyPath keys;
        defaultSopsFile = ../../../secrets/nixos.yaml;
        age = {
          keyFile = "/var/lib/sops-nix/key.txt";
          generateKey = true;
        };
        secrets =
          hostSecrets
          // {
            common = {};
            hashedPassword = {};
            nebula-ca = {
              format = "binary";
              sopsFile = ../../../secrets/nebula/ca.yaml;
            };
          };
        # templates = {
        #  example = {
        #    name = "example.cfg";
        #    content = ''
        #      example_info = "${config.sops.placeholder.common}"
        #    '';
        #  };
        # };
      };
    };
  }
