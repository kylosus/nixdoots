{
  params,
  lib,
  ...
}: {
  networking = {
    useDHCP = lib.mkDefault true;
    hostName = params.hostName;
    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [22];
    };
  };

  # TODO: Should this be here?
  programs.nm-applet.enable = true;
}
