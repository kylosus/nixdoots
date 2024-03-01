{
  params,
  lib,
  ...
}: {
  networking.useDHCP = lib.mkDefault true;
  networking.hostName = params.hostname;
  networking.networkmanager.enable = true;
}
