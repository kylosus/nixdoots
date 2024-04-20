{...}: {
  home.packages = with pkgs; [ i3-layouts ];

  xsession.windowManager.i3.extraConfig = ''
    set $i3l autosplit to workspace 1
  '';
}