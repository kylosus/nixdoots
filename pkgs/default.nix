# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs}: {
  # newpackage = pkgs.callPackage ./newpackage { };
  pywal = pkgs.python3Packages.callPackage ./pywal16 {};
  mpv-discordRPC = pkgs.mpvScripts.callPackage ./mpv-discordRPC {};
}
