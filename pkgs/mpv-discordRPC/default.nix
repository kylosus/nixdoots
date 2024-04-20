{ lib
, fetchFromGitHub
, unstableGitUpdater
, buildLua }:

buildLua rec {
  pname = "mpv-discordRPC";
  version = "1.4.1-UNKNOWN";

  src = fetchFromGitHub {
    owner = "cniw";
    repo  = "mpv-discordRPC";
    rev   = "v${version}";
    hash  = "sha256-JEGxuhx8VKbTLSjEukirm5Imy8mNCWwiwyswylteXTE";
  };

  #scriptPath = ".";
  passthru.scriptName = pname; 

  meta = {
    description = "Discord Rich Presence integration for mpv Media Player";
    #longDescription = ''
    #'';
    homepage = "https://github.com/cniw/mpv-discordRPC";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}

