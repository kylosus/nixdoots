{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [i3-layouts];

  # Can probably be done better
  xsession.windowManager.i3.extraConfig = ''
    set $i3l autosplit to workspace 1
    set $i3l autosplit to workspace 2
    set $i3l autosplit to workspace 3
    set $i3l autosplit to workspace 4
    set $i3l autosplit to workspace 5
    set $i3l autosplit to workspace 6
    set $i3l autosplit to workspace 7
    set $i3l autosplit to workspace 8
    set $i3l autosplit to workspace 9
    set $i3l autosplit to workspace 10
  '';

  xsession.windowManager.i3.config.startup = [
    {
      command = "${lib.getBin pkgs.i3-layouts}/bin/i3-layouts";
      always = true;
    }
  ];

  # systemd.user.services = {
  #   i3-layouts = {
  #     Unit = {
  #       Description = "i3 layouts";
  #       PartOf = ["i3-session.target"];
  #       # After = ["xrandr.service" "picom.service"];
  #     };
  #     Service = {
  #       ExecStart = "${lib.getBin pkgs.i3-layouts}/bin/i3-layouts";
  #       # RemainAfterExit = true;
  #       Type = "simple";
  #     };
  #     Install.WantedBy = ["i3-session.target"];
  #   };
  # };
}
