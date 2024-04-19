{
  params,
  lib,
  ...
}: {
  networking.useDHCP = lib.mkDefault true;
  networking.hostName = params.hostName;
  networking.networkmanager.enable = true;

  programs.nm-applet.enable = true;
}
