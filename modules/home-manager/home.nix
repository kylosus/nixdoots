{
  config,
  outputs,
  ...
}: {
  nixpkgs = {
    overlays = [
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];

    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home.stateVersion = "23.05";
}
