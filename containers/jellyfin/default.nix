{mediaMounts ? []}: {
  vars,
  containerLib,
  ...
}: let
  name = "jellyfin";

  inherit (vars.nixContainer.services.jellyfin) hostAddress localAddress;
  port = 8096;

  renderDevice = "/dev/dri/renderD128";
in {
  imports = [
    (containerLib.mkNixContainer {
      inherit hostAddress localAddress;
      inherit name;

      userUid = 1000;
      userName = "jellyfin";

      hasNetworkAccess = true;
      hasNebulaAccess = true;
      allowedTCPPorts = [port];
      hardenedServices = ["jellyfin"];

      extraContainersOptions = {
        # Intel iGPU for VA-API transcoding. The render node is 0666 on the host,
        # so it is usable from the user namespace without any gid mapping.
        allowedDevices = [
          {
            node = renderDevice;
            modifier = "rw";
          }
        ];
        bindMounts."${renderDevice}" = {
          hostPath = renderDevice;
          isReadOnly = false;
        };

        # Mount media directories at the container level
        extraFlags = map (p: "--bind-ro=${p}:${p}:norbind,idmap") mediaMounts;
      };

      extraContainersModule = {
        config,
        pkgs,
        ...
      }: {
        # container's nixos config
        # Enable hardware in the container
        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            # VA-API (iHD) for the i7-8700T's UHD 630
            intel-media-driver
            # OpenCL for HDR tone mapping on Gen9
            intel-compute-runtime-legacy1
          ];
        };

        # Actual jellyfin config
        services.jellyfin = {
          enable = true;
          openFirewall = false;

          hardwareAcceleration = {
            enable = true;
            type = "vaapi";
            device = renderDevice;
          };

          # Keep encoding settings declarative
          forceEncodingConfig = true;
          transcoding = {
            enableHardwareEncoding = true;
            enableToneMapping = true;
            # Coffee Lake (UHD 630) capabilities
            hardwareDecodingCodecs = {
              h264 = true;
              hevc = true;
              hevc10bit = true;
              mpeg2 = true;
              vc1 = true;
              vp8 = true;
              vp9 = true;
            };
            hardwareEncodingCodecs.hevc = true;
          };
        };

        systemd.services.jellyfin = {
          environment.LIBVA_DRIVER_NAME = "iHD";
          # Writable under the ProtectSystem=strict from hardenedServices
          serviceConfig.ReadWritePaths = let
            cfg = config.services.jellyfin;
          in [cfg.dataDir cfg.cacheDir];
        };
      };
    })
  ];
}
