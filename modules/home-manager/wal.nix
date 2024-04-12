{
  config,
  params,
  pkgs,
  ...
}: {
  xresources.extraConfig = "#include \"${config.xdg.cacheHome}/wal/colors.Xresources\"";

  programs.pywal = {
    enable = true;
  };
}
