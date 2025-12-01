{
  lib,
  pkgs,
  osConfig ? null,
  ...
}: {
  home.packages = with pkgs; [slock];

  services.screen-locker = {
    enable = true;
    inactiveInterval = 5;
    # TODO: standardize this
    lockCmd = lib.optionalString (osConfig != null) "/run/wrappers/bin/" + "slock";
    xautolock.extraOptions = ["-lockaftersleep"];
  };

  systemd.user.services = {
    xautolock-session.Install.WantedBy = lib.mkForce ["i3-session.target"];
    xss-lock.Install.WantedBy = lib.mkForce ["i3-session.target"];
  };
}
