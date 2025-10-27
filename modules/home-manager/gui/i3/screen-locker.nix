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
    lockCmd = "slock";
    xautolock.extraOptions = ["-lockaftersleep"];
  };

  systemd.user.services = {
    xautolock-session.Install.WantedBy = lib.mkForce ["i3-session.target"];
    xss-lock.Install.WantedBy = lib.mkForce ["i3-session.target"];
  };
}
