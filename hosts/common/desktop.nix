# My desktop for machines with desktops
{pkgs, ...}: {
  imports = [
    # Load up gui
    ../../modules/home-manager/gui

    # Applications
    ../../modules/home-manager/gui/applications/mpv
    ../../modules/home-manager/tui/applications/syncthing.nix
  ];

  # More applications
  home.packages = with pkgs; [
    firefox
    deluge
    stable.ffmpeg
    neovim
    stable.obsidian
    zathura
  ];
}
