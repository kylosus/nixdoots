###
# Usage:
#
# Inside
# - target: ssh -p 2222 -N -R 3333:localhost:22 tunnel@Proxy -p 2222
# - This will make localhost:22 available at Proxy container port 3333
# - Alternatively use autossh -M 1234 ...
#
# In the proxy:
# - sudo nixos-container root-login reverse-ssh
# - ssh user@localhost -p 4444
###
{
  pkgs,
  config,
  secrets,
  ...
}: {
  containers.reverse-ssh = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.250.0.1";
    localAddress = "10.250.0.2";
    ephemeral = false;

    config = {
      config,
      pkgs,
      ...
    }: {
      networking.hostName = "reverse-ssh-container";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [22];
      };

      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = true;
          ClientAliveInterval = 30;
          ClientAliveCountMax = 3;
        };
        extraConfig = ''
          Match User tunnel
            PasswordAuthentication yes
            AllowTcpForwarding yes
            GatewayPorts no
            PermitTTY no
            X11Forwarding no
            AllowAgentForwarding no
            PermitTunnel no
            ForceCommand /bin/false
            MaxSessions 1
        '';
      };

      users.users.tunnel = {
        isNormalUser = true;
        createHome = false;
        description = "Reverse SSH tunnel";
        shell = "${pkgs.util-linux}/bin/nologin";
        password = secrets.tunnelPassword;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [2222];
  networking.nat.enable = true;
  networking.nat.forwardPorts = [
    {
      sourcePort = 2222;
      destination = "10.250.0.2:22";
      proto = "tcp";
    }
  ];
}
