{
  pkgs,
  params,
  ...
}: {
  virtualisation = {
    libvirtd = {
      enable = true;
      # Used for UEFI boot of Home Assistant OS guest image
      qemuOvmf = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # For virt-install
    stable.virt-manager

    # For lsusb
    stable.usbutils
  ];

  users.users."${params.userName}".extraGroups = ["libvirtd"];
}
