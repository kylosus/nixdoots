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
  };

  # systemd.user.services.dunst.Service.Environment = lib.mkForce "${config.xdg.cacheHome}/wal/colors.sh";
  # systemd.user.services.dunst.Service.ExecStart = lib.mkForce "/bin/sh -c '. ${config.xdg.cacheHome}/wal/colors.sh; ${pkgs.dunst}/bin/dunst -frame_width 2 -lb $background -nb $color0 -cb \${color0} -lf \${color7} -bf \${color7} -cf \${color7} -nf \${color7}'";
}
