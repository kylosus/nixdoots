{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [i3lock];

  services.screen-locker = {
    enable = true;
    inactiveInterval = 5;
    # Pure Home-manager compatibility
    lockCmd = "i3lock";
    xautolock.extraOptions = ["-lockaftersleep"];
  };

  systemd.user.services = {
    xautolock-session.Install.WantedBy = lib.mkForce ["i3-session.target"];
    xss-lock.Install.WantedBy = lib.mkForce ["i3-session.target"];
  };
}
