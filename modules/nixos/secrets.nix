{ config, inputs, lib, outputs, pkgs, params, ... }:

let
  inherit (params) hostName;
  # hostsecrets = ../../hosts/${hostName}/secrets/secrets.yaml;
  cfg = config.host.feature.secrets;
in
  with lib;
{
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
      # defaultSopsFile = ../../hosts/common/secrets/example.yaml;
      age = {
        keyFile = "/var/lib/sops-nix/key.txt";
	generateKey = true;
      };
      secrets = {
        #${hostName} = {
        #  sopsFile = hostsecrets;
        #};
        common = {
          sopsFile = ../../hosts/common/secrets.yaml;
        };
      };
      #templates = {
      #  example = {
      #    name = "example.cfg";
      #    content = ''
      #      example_info = "${config.sops.placeholder.common}"
      #    '';
      #  };
      #};
    };
  };
}
