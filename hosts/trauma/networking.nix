{
  lib,
  secrets,
  params,
  ...
}: let
  host = secrets.hosts.trauma;
  interface = "eth0";
in {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [
      "8.8.8.8"
    ];
    defaultGateway = host.gateway;
    defaultGateway6 = {
      address = "";
      inherit interface;
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces = {
      "${interface}" = {
        ipv4.addresses = [
          {
            address = host.ip;
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = host.ipv6;
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = host.gateway;
            prefixLength = 32;
          }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="${host.macAddress}", NAME="${interface}"

  '';
}
