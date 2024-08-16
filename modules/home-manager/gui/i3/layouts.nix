{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [i3-layouts];

  xsession.windowManager.i3.extraConfig = let
    workspaces = map (x: x.workspace) config.xsession.windowManager.i3.config.workspaceOutputAssign;
    workspacesConfig = map (x: "set $i3l autosplit to workspace ${x}") workspaces;
  in
    lib.concatStringsSep "\n" workspacesConfig;

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
