{...}: {
  mkOverlays = path: {
    inputs,
    lib,
    config,
    ...
  }: let
    overlays = import path {inherit inputs lib config;};
  in [
    overlays.additions
    overlays.modifications
    overlays.unstable-packages
    overlays.stable-packages
  ];
}
