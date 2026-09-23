{
  params,
  modulesPath,
  lib,
  config,
  ...
}: let
  hasBootDisk = builtins.hasAttr "bootDisk" params.fs;
in {
  options = {
    host.secureBoot = {
      enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "Enables secure boot (limine)";
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = config.host.secureBoot.enable -> hasBootDisk;
        message = "`params.fs` must have a `bootDisk` when `secureBoot` is enabled.";
      }
    ];

    boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usbhid" "usb_storage"];
    boot.kernelModules = lib.mkDefault ["kvm-amd"];

    boot.initrd.kernelModules = ["xhci_pci" "usbhid" "usb_storage"];
    boot.extraModulePackages = lib.mkDefault [];

    boot.loader = lib.mkIf hasBootDisk {
      efi.canTouchEfiVariables = lib.mkDefault true;
      efi.efiSysMountPoint = lib.mkDefault "/boot";
      systemd-boot = lib.mkIf (!config.host.secureBoot.enable) {
        enable = lib.mkDefault true;
      };

      # Secure boot
      limine = lib.mkIf (config.host.secureBoot.enable) {
        enable = true;
        secureBoot = {
          enable = true;
          autoEnrollKeys.enable = true;
          autoGenerateKeys = true;
        };
        efiInstallAsRemovable = lib.mkDefault false;
      };
    };

    # boot.loader.systemd-boot.enable = builtins.hasAttr "/boot" config.fileSystems;

    boot.initrd.luks.devices = lib.mkIf (builtins.hasAttr "luksDisk" params.fs) (lib.mkDefault {
      root = {
        device = params.fs.luksDisk;
        preLVM = true;
      };
    });
  };
}
