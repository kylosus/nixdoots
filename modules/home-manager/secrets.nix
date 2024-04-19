{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.packages = with pkgs; [
    age
    sops
  ];

  sops = {
    defaultSopsFile = ../../secrets/home.yaml;
    age = {
      keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
      generateKey = true;
    };
    # defaultSymlinkPath = "/run/user/1000/secrets";
    # defaultSecretsMountPoint = "/run/user/1000/secrets.d";
    secrets = {
      common = {};
      # hashedPassword = {};
      # ssh-hosts = {};
    };
  };
}
