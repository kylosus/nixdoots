{
  params,
  modulesPath,
  lib,
  config,
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

  boot.loader.systemd-boot.enable = builtins.hasAttr "/boot" config.fileSystems;

  #boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  boot.initrd.luks.devices = lib.mkIf (builtins.hasAttr "luksDisk" params.fs) (lib.mkDefault {
    root = {
      device = params.fs.luksDisk;
      preLVM = true;
    };
  });
}
