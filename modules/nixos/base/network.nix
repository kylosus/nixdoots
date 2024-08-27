{
  params,
  lib,
  config,
  services,
  vars,
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
        enable = lib.mkDefault true;
        plugins = lib.mkForce [];
      };

      firewall = {
        enable = lib.mkForce true;
        # 22 for the tarpit
        allowedTCPPorts = [22 vars.ssh.port] ++ lib.optionals config.services.caddy.enable [80 443];
      };
    };
  };
}
