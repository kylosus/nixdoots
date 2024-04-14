{
  params,
  modulesPath,
  lib,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/all-hardware.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usbhid" "usb_storage"];
  boot.kernelModules = ["kvm-amd"];

  boot.initrd.kernelModules = ["xhci_pci" "usbhid" "usb_storage"];
  boot.extraModulePackages = [];

  boot.loader.systemd-boot.enable = true;

  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = lib.mkDefault {
    root = {
      device = params.fs.luksDisk;
      preLVM = true;
    };
  };
}
