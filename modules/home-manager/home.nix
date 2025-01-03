{
  inputs,
  config,
  outputs,
  lib,
  functions,
  ...
}: {
  nixpkgs = {
    overlays = functions.mkOverlays outputs.overlays {inherit inputs lib config;};

    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home.activation.installPackages = {
    data = lib.mkForce "";
    before = lib.mkForce [];
    after = lib.mkForce [];
  };

  # home.packages = lib.mkForce [];
  # home.profileDirectory = lib.mkForce "${config.home.homeDirectory}/.home-profile";

  home.stateVersion = "24.11";
}
