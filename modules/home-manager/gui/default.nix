{pkgs, ...}: {
  imports = [
    ./i3
    ./terminal.nix
  ];

  home.packages = with pkgs; [keepassxc];
}
