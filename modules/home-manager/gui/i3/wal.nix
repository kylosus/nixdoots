{
  config,
  params,
  pkgs,
  lib,
  ...
}: {
  xresources.extraConfig = "#include \"${config.xdg.cacheHome}/wal/colors.Xresources\"";

  programs.pywal = {
    enable = true;
    package = pkgs.pywal16;
  };
}
