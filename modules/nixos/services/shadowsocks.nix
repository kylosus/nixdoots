{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.host.shadowsocks;
in {
  options = {
    host.shadowsocks = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 8443;
        description = "Port (TCP and UDP) the shadowsocks server listens on";
      };

      passwordFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to the shadowsocks password";
      };
    };
  };

  config = {
    networking.firewall = {
      allowedTCPPorts = [cfg.port];
      allowedUDPPorts = [cfg.port];
    };

    services.shadowsocks = {
      enable = true;
      # Rust implementation, the libev one is unmaintained
      package = pkgs.shadowsocks-rust;
      # shadowsocks-rust only accepts a single string, "::" is dual-stack
      localAddress = "::";
      port = cfg.port;
      mode = "tcp_and_udp";
      # Recommended and works on my phone
      encryptionMethod = "aes-256-gcm";
      passwordFile = cfg.passwordFile;
    };
  };
}
