{
  params,
  pkgs,
  config,
  files,
  secrets,
  ...
}: {
  time.timeZone = params.timeZone;
  i18n.defaultLocale = "en_US.UTF-8";

  programs.fish.enable = true;

  users.users = {
    "${params.userName}" = {
      description = params.fullName;
      shell = pkgs.fish;
      # hashedPasswordFile = config.sops.secrets.hashedPassword.path;
      hashedPassword = secrets.hashedPassword;
      isNormalUser = true;
      openssh.authorizedKeys.keyFiles = [files.ssh-authorized];
      extraGroups = ["wheel" params.userName];
    };
  };

  users.users.root.hashedPassword = secrets.hashedPassword;
}
