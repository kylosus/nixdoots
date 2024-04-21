# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs}: {
  # newpackage = pkgs.callPackage ./newpackage { };
  i3-layouts = pkgs.python3Packages.callPackage ./i3-layouts {};
  mpv-discordRPC = pkgs.mpvScripts.callPackage ./mpv-discordRPC {};
  # pywal = pkgs.python3Packages.callPackage ./pywal16 {};
}
