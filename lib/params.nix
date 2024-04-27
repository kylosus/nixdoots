{files, ...}: {
  system ? "x86_64-linux",
  timeZone,
  hostName,
  userName ? "user",
  fullName ? "User",
  desktop ? false,
  wallpaper ? files.wallpaper,
  fs ? {},
}: {
  inherit system;
  inherit timeZone;

  inherit hostName;
  inherit userName;
  inherit fullName;
  inherit desktop;
  inherit wallpaper;

  inherit fs;

  # fs = {
  #  inherit (fs) luksDisk;
  #  inherit (fs) rootDisk;
  #  inherit (fs) bootDisk;
  #};
}
