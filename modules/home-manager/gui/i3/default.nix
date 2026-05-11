{pkgs, ...}: {
  imports = [
    ./common.nix
    ./i3.nix
    ./layouts.nix
    ./x11-session.nix
    ../bars/polybar.nix
  ];

  # Identifies the systemd user target every shared/i3 unit binds to.
  host.session.target = "i3-session.target";

  home.packages = with pkgs; [
    arandr
    xclip
    xsel
    nautilus
    font-awesome_6
  ];
}
