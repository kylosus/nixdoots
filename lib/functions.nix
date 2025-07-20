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

  mkBtrfs = {
    device,
    rootSubvol ? ".snapshots/1/snapshot",
    subvols,
    btrfsOptions ? ["relatime" "compress-force=zstd"],
  }: let
    mkEntry = subvol: {
      name = "/${subvol}";
      value = {
        inherit device;
        fsType = "btrfs";
        options = ["subvol=@/${subvol}"] ++ btrfsOptions;
      };
    };

    rootEntry = {
      name = "/";
      value = {
        inherit device;
        fsType = "btrfs";
        options = ["subvol=@/${rootSubvol}"] ++ btrfsOptions;
      };
    };
  in
    builtins.listToAttrs ([rootEntry] ++ map mkEntry subvols);
}
