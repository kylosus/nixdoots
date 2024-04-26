{
  params,
  lib,
  config,
  ...
}: let
  cfg = config.host.global;
in {
  config = {
    # Add nm-applet if desktop-y
    programs.nm-applet.enable = cfg.desktop;

    networking = {
      useDHCP = lib.mkDefault true;
      hostName = params.hostName;
      networkmanager.enable = true;

      firewall = {
        enable = true;
        allowedTCPPorts = [22];
      };
    };
  };
}
