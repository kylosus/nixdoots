{config, ...}: {
  # Make the secret available
  sops.secrets.ssh-hosts = {};

  # TODO: Some OpenSSH apps (jetbrains) break when ~/.ssh/config is a symlink because of permissions
  # See https://github.com/nix-community/home-manager/issues/322
  # Can alternativeely patch openssh itself (https://github.com/nix-community/home-manager/issues/322#issuecomment-1178614454)
  home.activation.createSshConfig = config.lib.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p $HOME/.ssh

        $DRY_RUN_CMD chmod 700 $HOME/.ssh

        $DRY_RUN_CMD rm $HOME/.ssh/config

        $DRY_RUN_CMD cat > $HOME/.ssh/config << 'EOF'
    Host *
      AddKeysToAgent yes
      ControlMaster no
      ControlPersist 10m
      include ${config.home.homeDirectory}/.ssh/hosts.d/hosts
    EOF

        $DRY_RUN_CMD chmod 600 $HOME/.ssh/config
  '';

  programs.ssh = {
    enable = false;
    enableDefaultConfig = false;
  };

  services.ssh-agent = {
    enable = true;
  };
}
