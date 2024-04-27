{
  params,
  modulesPath,
  lib,
  ...
}: {
  # Import it if you need it
  # imports = [
  #   (modulesPath + "/profiles/all-hardware.nix")
  # ];

  boot.initrd.availableKernelModules = lib.mkDefault ["xhci_pci" "nvme" "usbhid" "usb_storage"];
  boot.kernelModules = lib.mkDefault ["kvm-amd"];

  boot.initrd.kernelModules = lib.mkDefault ["xhci_pci" "usbhid" "usb_storage"];
  boot.extraModulePackages = lib.mkDefault [];

  boot.loader.systemd-boot.enable = lib.mkDefault true;

  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  boot.initrd.luks.devices = lib.mkDefault {
    root = {
      device = params.fs.luksDisk;
      preLVM = true;
    };
  };
}
