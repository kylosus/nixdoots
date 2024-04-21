# My desktop for machines with desktops
{...}: {
  imports = [
    ../../modules/home-manager/gui

    # Applications
    ../../modules/home-manager/gui/applications/mpv
    ../../modules/home-manager/tui/applications/syncthing.nix
  ];
}
