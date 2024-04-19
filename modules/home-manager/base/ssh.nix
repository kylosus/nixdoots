{...}: {
  # TODO: temporary
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };
}
