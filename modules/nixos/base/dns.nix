{lib, ...}: {
  networking = {
    nameservers = lib.mkForce ["127.0.0.1" "::1"];
    # If using dhcpcd:
    dhcpcd.extraConfig = "nohook resolv.conf";
    # If using NetworkManager:
    networkmanager.dns = "none";
  };

  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;
      doh_servers = true;
      require_nolog = true;
      require_nofilter = true;

      bootstrap_resolvers = ["1.1.1.1:53"];
    };
  };

  systemd.services.dnscrypt-proxy.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };
}
