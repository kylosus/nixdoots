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
    arandr
    bindfs
    deluge
    discord
    ffmpeg
    gimp
    neovim
    obsidian
    spotify
    ungoogled-chromium
    unzip
    zathura
  ];
}
