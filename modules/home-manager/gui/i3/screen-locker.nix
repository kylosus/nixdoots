{
  lib,
  pkgs,
  params,
  ...
}: {
  home.packages = with pkgs; [i3lock];

  services.screen-locker = {
    enable = true;
    inactiveInterval = 5;
    # Pure Home-manager compatibility
    # The wallpaper has to be a PNG...
    lockCmd = "i3lock --image ${params.wallpaper}";
    xautolock.extraOptions = ["-lockaftersleep"];
  };

  systemd.user.services = {
    xautolock-session.Install.WantedBy = lib.mkForce ["i3-session.target"];
    xss-lock.Install.WantedBy = lib.mkForce ["i3-session.target"];
  };
}
