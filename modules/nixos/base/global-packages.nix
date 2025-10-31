{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # The most important
    fish

    # essential
    git
    git-crypt
    wget
    curl
    vim
    neovim
    rsync

    # utils
    ripgrep
    dust
    fd

    # monitoring
    htop
    lsof

    # For later
    # nix-index
    # iotop
    # iftop
    # strace
    # ltrace
    # sysstat
    # lm_sensors
    # ethtool
    # usbutils
    # pciutils

    # jq

    # gnutar
    # zip
    # zstd
    # xz

    # networking tools
    # dnsutils
    # nmap
    # tcpdump

    # misc
    # sl
    # lolcat
    # cowsay
    # file
    # which
    # tree
    # gnused
    # gawk
    # gnupg
  ];
}
