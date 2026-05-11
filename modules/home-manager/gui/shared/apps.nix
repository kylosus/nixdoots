{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    feh
    nautilus
  ];

  xdg.mimeApps.defaultApplications = {
    "image/bmp" = lib.mkForce "feh.desktop";
    "image/gif" = lib.mkForce "feh.desktop";
    "image/jpeg" = lib.mkForce "feh.desktop";
    "image/jpg" = lib.mkForce "feh.desktop";
    "image/pjpeg" = lib.mkForce "feh.desktop";
    "image/png" = lib.mkForce "feh.desktop";
    "image/tiff" = lib.mkForce "feh.desktop";
    "image/webp" = lib.mkForce "feh.desktop";
    "image/x-bmp" = lib.mkForce "feh.desktop";
    "image/x-pcx" = lib.mkForce "feh.desktop";
    "image/x-png" = lib.mkForce "feh.desktop";
    "image/x-portable-anymap" = lib.mkForce "feh.desktop";
    "image/x-portable-bitmap" = lib.mkForce "feh.desktop";
    "image/x-portable-graymap" = lib.mkForce "feh.desktop";
    "image/x-portable-pixmap" = lib.mkForce "feh.desktop";
    "image/x-tga" = lib.mkForce "feh.desktop";
    "image/x-xbitmap" = lib.mkForce "feh.desktop";
    "text/html" = lib.mkForce "chromium-browser.desktop";
    "x-scheme-handler/http" = lib.mkForce "chromium-browser.desktop";
    "x-scheme-handler/https" = lib.mkForce "chromium-browser.desktop";
    "x-scheme-handler/about" = lib.mkForce "chromium-browser.desktop";
    "x-scheme-handler/unknown" = lib.mkForce "chromium-browser.desktop";
    "inode/directory" = lib.mkForce "nautilus.desktop";
  };
}
