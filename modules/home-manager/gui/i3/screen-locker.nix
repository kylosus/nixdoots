{
  lib,
  pkgs,
  params,
  ...
}: {
  home.packages = with pkgs; [slock];

  services.screen-locker = {
    enable = true;
    inactiveInterval = 5;
    # Pure Home-manager compatibility
    # The wallpaper has to be a PNG...
    # lockCmd = "${lib.getExe pkgs.i3lock} --image ${params.wallpaper}";
    lockCmd = "${lib.getExe pkgs.slock}";
    xautolock.extraOptions = ["-lockaftersleep"];
  };

  systemd.user.services = {
    xautolock-session.Install.WantedBy = lib.mkForce ["i3-session.target"];
    xss-lock.Install.WantedBy = lib.mkForce ["i3-session.target"];
  };
}
