# TODO: For testing for now. Should add a function to make nebula network creation easier
{
  pkgs,
  config,
  lib,
  params,
  secrets,
  hostPath,
  ...
}: {
  config = let
    name = "lab";
    tunDevice = "nebula.${name}";

    trustedGroup = "ssh";

    lighthouseIp = "10.31.0.1";
    lighthousePort = "4243";
    lighthouseRoutableIp = "${secrets.hosts.kagamine.ip}:${lighthousePort}";

    sopsCa = "${name}-nebula-ca";
    sopsKey = "${params.hostName}-${name}-nebula-key";
    sopsCert = "${params.hostName}-${name}-nebula-cert";
    owner = config.systemd.services."nebula@${name}".serviceConfig.User;

    mkSecret = sopsFile: {
      format = "binary";
      inherit sopsFile;
      inherit owner;
    };

    accumulatePorts = acc: item: let
      proto = item.proto;
      port = item.port;
      existingPorts =
        if acc ? ${proto}
        then acc.${proto}
        else [];
    in
      acc // {${proto} = existingPorts ++ [(lib.toInt port)];};
  in {
    environment.systemPackages = with pkgs; [nebula];

    # Secrets
    sops.secrets."${sopsCa}" = mkSecret ./ca.json;
    sops.secrets."${sopsKey}" = mkSecret ./key.json;
    sops.secrets."${sopsCert}" = mkSecret ./cert.json;

    services.nebula.networks."${name}" = rec {
      enable = true;
      isLighthouse = true;

      listen.port = lib.toIntBase10 lighthousePort;

      lighthouses = [lighthouseIp];

      staticHostMap = {
        "${lighthouseIp}" = [lighthouseRoutableIp];
      };

      isRelay = true;
      relays = [lighthouseIp];
      tun = {
        device = tunDevice;
      };

      settings.lighthouse.dns = lib.mkForce false;

      firewall.outbound = [
        {
          port = "any";
          proto = "any";
          host = "any";
        }
      ];

      firewall.inbound = [
        # Allow ping from anyone
        {
          port = "any";
          proto = "icmp";
          host = "any";
        }

        # Just in case
        {
          port = "22";
          proto = "tcp";
          groups = [trustedGroup];
        }
      ];

      # Actual nebula config setup
      ca = config.sops.secrets."${sopsCa}".path;
      key = config.sops.secrets."${sopsKey}".path;
      cert = config.sops.secrets."${sopsCert}".path;
    };

    # Open the chosen ports
    networking.firewall.interfaces."${tunDevice}" = let
      filteredPorts = lib.unique (builtins.filter (x: x.port != "any") config.services.nebula.networks."${name}".firewall.inbound);
      ports = builtins.foldl' accumulatePorts {} filteredPorts;
    in {
      allowedTCPPorts = ports.tcp or [];
      allowedUDPPorts = ports.udp or [];
    };

    systemd.services."nebula@${name}".after = ["sops-nix.service"];
  };
}
