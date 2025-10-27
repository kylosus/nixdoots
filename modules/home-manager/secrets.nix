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
    secrets = {
      common = {};
    };
  };
}
