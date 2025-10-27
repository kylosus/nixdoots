{
  params,
  modulesPath,
  lib,
  config,
  ...
}: {
  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usbhid" "usb_storage"];
  boot.kernelModules = lib.mkDefault ["kvm-amd"];

  boot.initrd.kernelModules = ["xhci_pci" "usbhid" "usb_storage"];
  boot.extraModulePackages = lib.mkDefault [];

  boot.loader = lib.mkIf (builtins.hasAttr "bootDisk" params.fs) (lib.mkDefault {
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
    systemd-boot.enable = true;
  });

  # boot.loader.systemd-boot.enable = builtins.hasAttr "/boot" config.fileSystems;

  boot.initrd.luks.devices = lib.mkIf (builtins.hasAttr "luksDisk" params.fs) (lib.mkDefault {
    root = {
      device = params.fs.luksDisk;
      preLVM = true;
    };
  });
}
