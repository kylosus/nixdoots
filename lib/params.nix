{files, ...}: {
  system ? "x86_64-linux",
  timeZone,
  hostName,
  userName ? "user",
  fullName ? "User",
  wallpaper ? files.wallpaper,
  fs,
}: {
  inherit system;
  inherit timeZone;

  inherit hostName;
  inherit userName;
  inherit fullName;
  inherit wallpaper;

  fs = {
    inherit (fs) luksDisk;
    inherit (fs) rootDisk;
    inherit (fs) bootDisk;
  };
}
