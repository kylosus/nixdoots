# This modules does not import aynthing
# but it's meant to be "global" between
# NixOS and home-manager.
# In the future this will likely be
# in a common/ directory
{
  config,
  lib,
  ...
}: {
  options.host.global = {
    desktop = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable graphical stuff";
    };

    # Probably shouldn't be "global"
    endlessh = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enables endlessh. For internet-facing hosts";
    };
  };
}
