{
  lib,
  fetchFromGitHub,
  unstableGitUpdater,
  buildLua,
  # luajitPackages,
  discord-rpc,
  stdenv,
}:
buildLua rec {
  pname = "mpv-discordRPC";
  version = "1.4.1-UNKNOWN";

  src = fetchFromGitHub {
    owner = "cniw";
    repo = "mpv-discordRPC";
    rev = "v${version}";
    hash = "sha256-JEGxuhx8VKbTLSjEukirm5Imy8mNCWwiwyswylteXTE";
  };

  buildInputs = [
    discord-rpc
  ];

  # Seems to be broken
  # nativeBuildInputs = with luajitPackages; [
  #   luaffi
  # ];

  postPatch = ''
    substituteInPlace ${scriptPath}/lua-discordRPC.lua \
      --replace "discord-rpc" "${discord-rpc}/lib/libdiscord-rpc${stdenv.hostPlatform.extensions.sharedLibrary}"
  '';

  passthru.updateScript = unstableGitUpdater {};

  dontBuild = false;
  scriptPath = pname;

  meta = {
    description = "Discord Rich Presence integration for mpv Media Player";
    homepage = "https://github.com/cniw/mpv-discordRPC";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [];
  };
}
