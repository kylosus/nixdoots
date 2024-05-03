{
  params,
  lib,
  config,
  services,
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
      networkmanager = {
        enable = true;
        # plugins = lib.mkForce [];
      };

      firewall = {
        enable = true;
        allowedTCPPorts = [22] ++ lib.optional config.services.caddy.enable [80 443];
      };
    };
  };
}
