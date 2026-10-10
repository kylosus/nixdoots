{
  lib,
  vars,
  ...
}: {
  # Import the module this returns
  mkNixContainer = {
    name,
    # Optional user created inside the container, e.g. to pin a service user's
    # uid to the owner of id-mapped mounts
    userName ? null,
    userUid ? 1000,
    hasNetworkAccess ? false,
    hasNebulaAccess ? false,
    allowedTCPPorts ? [],
    # Services inside the container that get a stricter sandbox. With
    # ProtectSystem=strict they need their state in ReadWritePaths (or
    # StateDirectory/CacheDirectory)
    hardenedServices ? [],
    hostAddress,
    localAddress,
    extraContainersOptions ? {},
    extraContainersModule ? {},
  }: {config, ...}: let
    veth = "ve-${name}";
    nebula = "nebula.${vars.nebula.name}";
    cfg = config.containers."${name}";
  in {
    assertions = [
      {
        assertion = config.networking.nftables.enable;
        message = "`networking.nftables.enable` must be set for container `${name}`";
      }
      {
        assertion = hasNebulaAccess -> config.host.nebula.enable;
        message = "`config.host.nebula.enable` must be set for `hasNebulaAccess`";
      }
      {
        assertion = cfg.privateNetwork;
        message = "Container `${name}` must keep `privateNetwork`, its firewall rules match on the veth";
      }
      {
        assertion = !(builtins.elem cfg.privateUsers ["no" "identity"]);
        message = "Container `${name}` must keep a private uid range (`privateUsers`)";
      }
    ];

    containers."${name}" = lib.mkMerge [
      {
        autoStart = true;

        # Map the container's uids/gids to an unused range on the host, so that
        # container root is not root/a real user on the host
        privateUsers = "pick";

        # Separate network namespace with a veth pair to the host
        privateNetwork = true;
        inherit hostAddress localAddress;

        config = {lib, ...}: {
          imports = [extraContainersModule];

          system.stateVersion = lib.mkDefault vars.stateVersion;

          # The host resolver is on localhost, which isn't reachable from here
          networking.useHostResolvConf = lib.mkForce false;
          networking.nameservers = lib.mkDefault ["1.1.1.1" "9.9.9.9"];

          # Only the given ports, regardless of what services' openFirewall adds
          networking.firewall = {
            allowedTCPPorts = lib.mkForce allowedTCPPorts;
            allowedUDPPorts = lib.mkForce [];
            allowedTCPPortRanges = lib.mkForce [];
            allowedUDPPortRanges = lib.mkForce [];
          };

          # Above module defaults (100), but can still be loosened with mkForce
          systemd.services = lib.genAttrs hardenedServices (_: {
            serviceConfig = lib.mapAttrs (_: lib.mkOverride 60) {
              ProtectSystem = "strict";
              ProtectHome = true;
              PrivateTmp = true;
            };
          });

          users = lib.optionalAttrs (userName != null) {
            groups."${userName}".gid = lib.mkDefault userUid;
            users."${userName}" = {
              uid = lib.mkDefault userUid;
              isSystemUser = lib.mkDefault true;
              group = lib.mkDefault userName;
            };
          };
        };
      }
      extraContainersOptions
    ];

    # # TODO
    # systemd.services."container@${name}" = {
    #   after = ["zfs-mount.service"];
    #   unitConfig.RequiresMountsFor = mediaMounts;
    # };

    networking = {
      nat = {
        # Turns on ip forwarding, which DNAT'd nebula connections also need
        enable = lib.mkIf (hasNetworkAccess || hasNebulaAccess) true;
        # Outbound access
        internalInterfaces = lib.mkIf hasNetworkAccess [veth];
      };

      firewall = {
        # Default-deny forwarding; nat allows the container out, and DNAT'd
        # connections (below) are accepted by the firewall
        filterForward = true;

        # Internet only, no LAN/nebula/other private networks.
        # TODO: should add hasLANAccess
        extraForwardRules = lib.mkBefore ''
          iifname "${veth}" ip daddr { 10.0.0.0/8, 100.64.0.0/10, 169.254.0.0/16, 172.16.0.0/12, 192.168.0.0/16 } reject
        '';
      };

      nftables.tables."container-${name}" = let
        portRules = lib.concatMapStringsSep "\n" (x: "iifname \"${nebula}\" tcp dport ${toString x} dnat ip to ${localAddress}") allowedTCPPorts;
      in {
        family = "inet";
        content =
          ''
            # Runs before the nixos firewall, whose globally open ports (ssh)
            # would otherwise be reachable from the container
            chain input {
              type filter hook input priority filter - 1;
              iifname "${veth}" ct state new drop
            }
          ''
          + lib.optionalString hasNebulaAccess ''
            # Expose the container on the host's nebula address
            chain prerouting {
              type nat hook prerouting priority dstnat;
              ${portRules}
            }
          '';
      };
    };

    services.nebula.networks = lib.mkIf hasNebulaAccess {
      "${vars.nebula.name}".firewall.inbound =
        map (x: {
          port = toString x;
          proto = "tcp";
          groups = [vars.nebula.trustedGroup];
        })
        allowedTCPPorts;
    };
  };
}
