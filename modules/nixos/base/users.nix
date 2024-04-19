{
  params,
  pkgs,
  config,
  files,
  ...
}: {
  time.timeZone = params.timeZone;
  i18n.defaultLocale = "en_US.UTF-8";

  programs.fish.enable = true;

  users.users = {
    "${params.username}" = {
      description = params.fullname;
      shell = pkgs.fish;
      hashedPasswordFile = config.sops.secrets.hashedPassword.path;
      isNormalUser = true;
      openssh.authorizedKeys.keyFiles = [files.ssh-authorized];
      extraGroups = ["wheel" params.username];
    };
  };
}
