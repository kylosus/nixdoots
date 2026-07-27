{pkgs, ...}: let
  name = "Fuchsia-Pop";
  version = "v2.0.1";
in {
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;

    inherit name;
    size = 24;

    package = pkgs.runCommand "moveUp" {} ''
      mkdir -p $out/share/icons
      ln -s ${pkgs.fetchzip {
        url = "https://github.com/ful1e5/fuchsia-cursor/releases/download/${version}/${name}.tar.xz";
        hash = "sha256-rjeDa/hRZVOS8XeTWEG0Uzf3nTWPd2leWQ2krQFVKks=";
      }} $out/share/icons/${name}
    '';
  };
}
