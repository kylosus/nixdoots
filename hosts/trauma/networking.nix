{
  lib,
  secrets,
  params,
  ...
}: let
  host = secrets.hosts.trauma;
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
      interface = "ens3";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces = {
      ens3 = {
        ipv4.addresses = [
          {
            address = host.ip;
            prefixLength = 32;
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
    ATTR{address}=="${host.macAddress}", NAME="ens3"

  '';
}
