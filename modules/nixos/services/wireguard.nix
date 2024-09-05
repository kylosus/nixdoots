{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.host.wireguard;
in {
  options = {
    host.wireguard = {
      ip = lib.mkOption {
        type = lib.types.str;
        default = "10.100.0.1/24";
        description = "IP address and subnet of the interface";
      };

      privateKeyFile = lib.mkOption {
        type = lib.types.str;
        description = "Path (string) to the wireguard private key";
      };
    };
  };

  config = let
    externalInterface = "eth0";
  in {
    # enable NAT
    networking.nat.enable = true;
    networking.nat.externalInterface = externalInterface;
    networking.nat.internalInterfaces = ["wg0"];
    networking.firewall = {
      allowedUDPPorts = [51820];
    };

    networking.wireguard.interfaces = {
      # "wg0" is the network interface name. You can name the interface arbitrarily.
      wg0 = {
        # Determines the IP address and subnet of the server's end of the tunnel interface.
        ips = [cfg.ip];

        # The port that WireGuard listens to. Must be accessible by the client.
        listenPort = 51820;

        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${cfg.ip} -o ${externalInterface} -j MASQUERADE
        '';

        # This undoes the above command
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${cfg.ip} -o ${externalInterface} -j MASQUERADE
        '';

        # Path to the private key file.
        #
        # Note: The private key can also be included inline via the privateKey option,
        # but this makes the private key world-readable; thus, using privateKeyFile is
        # recommended.
        privateKeyFile = cfg.privateKeyFile;
      };
    };
  };
}
